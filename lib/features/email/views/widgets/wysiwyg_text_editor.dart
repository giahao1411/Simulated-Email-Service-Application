import 'dart:convert'; // Để mã hóa base64
import 'dart:typed_data';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart'; // Import trực tiếp để sử dụng TextSelection
import 'package:provider/provider.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class WysiwygTextEditor extends StatefulWidget {
  const WysiwygTextEditor({
    required this.controller,
    required this.onClose,
    this.onSave,
    this.isCompact = false,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onClose;
  final VoidCallback? onSave;
  final bool isCompact;

  @override
  State<WysiwygTextEditor> createState() => WysiwygTextEditorState();
}

// Custom embed builder for images
class ImageEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(
    BuildContext context,
    quill.QuillController controller,
    quill.Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    final imageUrl = node.value.data as String;
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 100,
          color: Colors.grey[300],
          child: const Center(child: Text('Không thể hiển thị ảnh')),
        );
      },
    );
  }
}

class WysiwygTextEditorState extends State<WysiwygTextEditor> {
  late final quill.QuillController _quillController;
  final FocusNode _focusNode = FocusNode();

  bool _showToolbar = true;
  String _currentHtml = '';

  @override
  void initState() {
    super.initState();
    _initializeQuillController();
    if (widget.isCompact) {
      _showToolbar = false;
    }
  }

  void _initializeQuillController() {
    try {
      final text = widget.controller.text.trim();
      debugPrint('Initializing with text: $text');

      _quillController = quill.QuillController.basic();

      if (text.isNotEmpty && text.contains('<') && text.contains('>')) {
        debugPrint('Processing HTML content...');
        _quillController.document.delete(0, _quillController.document.length);
        _insertHtmlContent(text);
      } else if (text.isNotEmpty) {
        _quillController.document.delete(0, _quillController.document.length);
        _quillController.document.insert(0, text);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _quillController.addListener(_updateTextController);
        setState(() {});
      });
    } catch (e) {
      debugPrint('Error initializing QuillController: $e');
      _quillController = quill.QuillController.basic();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _quillController.addListener(_updateTextController);
      });
    }
  }

  void _insertHtmlContent(String html) {
    try {
      String workingHtml = html.replaceAll(RegExp(r'</?p[^>]*>'), '').trim();

      int currentOffset = 0;
      final strongPattern = RegExp(r'<strong[^>]*>(.*?)</strong>');
      final matches = strongPattern.allMatches(workingHtml);

      if (matches.isEmpty) {
        final plainText = _stripHtmlTags(workingHtml);
        if (plainText.isNotEmpty) {
          _quillController.document.insert(0, plainText);
        }
        return;
      }

      int lastEnd = 0;

      for (final match in matches) {
        if (match.start > lastEnd) {
          final beforeText =
              _stripHtmlTags(
                workingHtml.substring(lastEnd, match.start),
              ).trim();
          if (beforeText.isNotEmpty) {
            _quillController.document.insert(currentOffset, beforeText);
            currentOffset += beforeText.length;
          }
        }

        final strongText = _stripHtmlTags(match.group(1) ?? '').trim();
        if (strongText.isNotEmpty) {
          _quillController.document.insert(currentOffset, strongText);
          _quillController.formatText(
            currentOffset,
            strongText.length,
            quill.Attribute.bold,
          );
          currentOffset += strongText.length;
        }

        lastEnd = match.end;
      }

      if (lastEnd < workingHtml.length) {
        final afterText = _stripHtmlTags(workingHtml.substring(lastEnd)).trim();
        if (afterText.isNotEmpty) {
          _quillController.document.insert(currentOffset, afterText);
        }
      }
    } catch (e) {
      debugPrint('Error inserting HTML content: $e');
      final plainText = _stripHtmlTags(html);
      _quillController.document.insert(0, plainText);
    }
  }

  String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(' ', ' ')
        .replaceAll('&', '&')
        .replaceAll('<', '<')
        .replaceAll('>', '>')
        .trim();
  }

  void _updateTextController() {
    try {
      final delta = _quillController.document.toDelta();
      final converter = QuillDeltaToHtmlConverter(
        delta.toJson(),
        ConverterOptions.forEmail(),
      );
      final html = converter.convert();
      _currentHtml = html;

      if (widget.controller.text != html) {
        widget.controller.text = html;
      }
    } catch (e) {
      debugPrint('Error converting delta to HTML: $e');
      final plainText = _quillController.document.toPlainText();
      if (widget.controller.text != plainText) {
        widget.controller.text = plainText;
        _currentHtml = plainText;
      }
    }
  }

  void insertImage(Uint8List imageBytes) {
    try {
      // Chuyển đổi ảnh thành base64
      final base64String = base64Encode(imageBytes);
      final imageUrl = 'data:image/png;base64,$base64String'; // Giả sử là PNG

      // Lấy vị trí con trỏ hiện tại
      final position = _quillController.selection.start;

      // Chèn ảnh vào vị trí con trỏ
      _quillController.document.insert(
        position,
        '\n',
      ); // Thêm dòng mới trước ảnh
      _quillController.document.insert(
        position + 1,
        quill.BlockEmbed.image(imageUrl), // Sử dụng BlockEmbed.image
      );
      _quillController.document.insert(
        position + 2,
        '\n',
      ); // Thêm dòng mới sau ảnh

      // Cập nhật con trỏ
      _quillController.updateSelection(
        TextSelection.collapsed(offset: position + 3),
        quill.ChangeSource.local,
      );

      // Cập nhật nội dung HTML
      _updateTextController();
    } catch (e) {
      debugPrint('Error inserting image: $e');
    }
  }

  void _toggleToolbar() {
    setState(() {
      _showToolbar = !_showToolbar;
    });
  }

  Widget _buildToolbar(bool isDarkMode) {
    if (!_showToolbar) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white12 : Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: quill.QuillToolbar.simple(
          configurations: quill.QuillSimpleToolbarConfigurations(
            controller: _quillController,
            showBoldButton: true,
            showItalicButton: true,
            showUnderLineButton: true,
            showStrikeThrough: true,
            showColorButton: true,
            showBackgroundColorButton: false,
            showListBullets: true,
            showListNumbers: true,
            showAlignmentButtons: true,
            showFontSize: true,
            showLink: true,
            showUndo: false,
            showRedo: false,
            showInlineCode: false,
            showClearFormat: false,
            showHeaderStyle: false,
            showListCheck: false,
            showCodeBlock: false,
            showQuote: false,
            showSearchButton: false,
            showClipboardCut: false,
            showClipboardCopy: false,
            showClipboardPaste: false,
            showSubscript: false,
            showSuperscript: false,
            showDividers: false,
            showFontFamily: false,
            showIndent: false,
            toolbarIconAlignment: WrapAlignment.start,
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(bool isDarkMode) {
    return Container(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: quill.QuillEditor.basic(
          configurations: quill.QuillEditorConfigurations(
            controller: _quillController,
            scrollable: widget.isCompact ? false : true,
            autoFocus: true,
            expands: true,
            padding: const EdgeInsets.only(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
            ),
            placeholder:
                widget.isCompact
                    ? 'Nhập tiêu đề...'
                    : 'Bắt đầu nhập nội dung email...',
            customStyles: quill.DefaultStyles(
              paragraph: quill.DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                const quill.VerticalSpacing(6, 0),
                const quill.VerticalSpacing(0, 0),
                null,
              ),
              h1: quill.DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                const quill.VerticalSpacing(6, 0),
                const quill.VerticalSpacing(0, 0),
                null,
              ),
              h2: quill.DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                const quill.VerticalSpacing(6, 0),
                const quill.VerticalSpacing(0, 0),
                null,
              ),
            ),
            embedBuilders: [
              ImageEmbedBuilder(),
            ], // Fixed: Using custom EmbedBuilder class
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quillController.removeListener(_updateTextController);
    _quillController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Container(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: Column(
        children: [
          Expanded(child: _buildEditor(isDarkMode)),
          if (!widget.isCompact) _buildToolbar(isDarkMode),
        ],
      ),
    );
  }
}
