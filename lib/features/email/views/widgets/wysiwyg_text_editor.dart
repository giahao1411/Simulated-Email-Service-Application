import 'dart:convert';
import 'dart:typed_data';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart' as quill;
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
    final base64String = imageUrl.replaceFirst('data:image/png;base64,', '');
    debugPrint('ImageEmbedBuilder - Decoding image: $base64String');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      constraints: const BoxConstraints(maxHeight: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          base64Decode(base64String),
          fit: BoxFit.contain,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('ImageEmbedBuilder - Error decoding image: $error');
            return Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Không thể hiển thị ảnh',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class WysiwygTextEditorState extends State<WysiwygTextEditor> {
  late final quill.QuillController _quillController;
  final FocusNode _focusNode = FocusNode();
  bool _showToolbar = true;
  late String _currentHtml;

  @override
  void initState() {
    super.initState();
    _initializeQuillController();
    if (widget.isCompact) {
      _showToolbar = false;
    }
    _currentHtml = widget.controller.text;
    debugPrint('WysiwygTextEditor - Initial HTML: $_currentHtml');
  }

  void _initializeQuillController() {
    try {
      final text = widget.controller.text.trim();
      debugPrint('Initializing with text: $text');

      _quillController = quill.QuillController.basic();

      if (text.isNotEmpty && text.contains('<') && text.contains('>')) {
        debugPrint('Processing HTML content...');
        _quillController.document.delete(0, _quillController.document.length);
        setHtml(text);
      } else if (text.isNotEmpty) {
        _quillController.document.delete(0, _quillController.document.length);
        _quillController.document.insert(0, text);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _quillController.addListener(_updateTextController);
        setState(() {});
      });
    } on Exception catch (e) {
      debugPrint('Error initializing QuillController: $e');
      _quillController = quill.QuillController.basic();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _quillController.addListener(_updateTextController);
      });
    }
  }

  void setHtml(String html) {
    try {
      debugPrint('Setting HTML: $html');
      final delta = _htmlToDelta(html.trim());
      _quillController.document = quill.Document.fromDelta(delta);
      _updateTextController();
    } on Exception catch (e) {
      debugPrint('Error setting HTML content: $e');
      final plainText = _stripHtmlTags(html);
      _quillController.document.insert(0, plainText.isEmpty ? '\n' : plainText);
      _updateTextController();
    }
  }

  quill.Delta _htmlToDelta(String html) {
    final delta = quill.Delta();
    final workingHtml = html.trim();

    final strongPattern = RegExp('<strong[^>]*>(.*?)</strong>');
    final italicPattern = RegExp('<em[^>]*>(.*?)</em>');
    final underlinePattern = RegExp('<u[^>]*>(.*?)</u>');
    final brPattern = RegExp(r'<br\s*/?>');
    final ulPattern = RegExp('<ul[^>]*>(.*?)</ul>', multiLine: true);
    final liPattern = RegExp('<li[^>]*>(.*?)</li>');
    final imgPattern = RegExp('<img[^>]*src="([^"]*)"[^>]*>');

    final allMatches = <RegExpMatch>[
      ...strongPattern.allMatches(workingHtml),
      ...italicPattern.allMatches(workingHtml),
      ...underlinePattern.allMatches(workingHtml),
      ...brPattern.allMatches(workingHtml),
      ...ulPattern.allMatches(workingHtml),
      ...liPattern.allMatches(workingHtml),
      ...imgPattern.allMatches(workingHtml),
    ]..sort((a, b) => a.start.compareTo(b.start));

    var lastEnd = 0;
    for (final match in allMatches) {
      if (match.start > lastEnd) {
        final beforeText = workingHtml.substring(lastEnd, match.start);
        final cleanedText = _preserveSpaces(beforeText);
        if (cleanedText.isNotEmpty) {
          delta.insert(cleanedText);
        }
      }

      if (match.pattern == brPattern) {
        delta.insert('\n');
      } else if (match.pattern == imgPattern) {
        final imageUrl = match.group(1) ?? '';
        if (imageUrl.startsWith('data:image/')) {
          delta
            ..insert('\n')
            ..insert(quill.BlockEmbed.image(imageUrl), {'image': true})
            ..insert('\n');
        }
      } else {
        final isStrong = match.pattern == strongPattern;
        final isItalic = match.pattern == italicPattern;
        final isUnderline = match.pattern == underlinePattern;
        final text = _preserveSpaces(match.group(1) ?? '');

        if (text.isNotEmpty) {
          final attributes = <String, dynamic>{};
          if (isStrong) attributes['bold'] = true;
          if (isItalic) attributes['italic'] = true;
          if (isUnderline) attributes['underline'] = true;
          delta.insert(text, attributes);
        }
      }
      lastEnd = match.end;
    }

    if (lastEnd < workingHtml.length) {
      final afterText = workingHtml.substring(lastEnd);
      final cleanedText = _preserveSpaces(afterText);
      if (cleanedText.isNotEmpty) {
        delta.insert(cleanedText);
      }
    }

    if (delta.isEmpty) delta.insert('\n');
    return delta;
  }

  String _preserveSpaces(String text) {
    final result = text
        .replaceAll(RegExp('<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&nbsp;', ' ');

    return result;
  }

  String _stripHtmlTags(String html) {
    final result = html
        .replaceAll(RegExp('<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&nbsp;', ' ');

    return result.trim();
  }

  void _updateTextController() {
    try {
      final delta = _quillController.document.toDelta();

      final converter = QuillDeltaToHtmlConverter(
        delta.toJson(),
        ConverterOptions(
          converterOptions: ConverterOptions.forEmail().converterOptions,
        ),
      );

      var html = converter.convert();

      html = _postProcessHtml(html);

      debugPrint('Updated HTML: $html');

      if (widget.controller.text != html) {
        widget.controller.text = html;
        _currentHtml = html;
      }
    } on Exception catch (e) {
      debugPrint('Error converting delta to HTML: $e');
      final plainText = _quillController.document.toPlainText();
      if (widget.controller.text != plainText) {
        widget.controller.text = plainText;
        _currentHtml = plainText;
      }
    }
  }

  String _postProcessHtml(String html) {
    return html.replaceAllMapped(RegExp(' {2,}'), (match) {
      final spaceCount = match.group(0)!.length;
      return ' ${'&nbsp;' * (spaceCount - 1)}';
    });
  }

  void insertImage(Uint8List imageBytes) {
    try {
      final base64String = base64Encode(imageBytes);
      final imageUrl = 'data:image/png;base64,$base64String';
      final position = _quillController.selection.start;

      _quillController.document.insert(position, '\n');
      _quillController.document.insert(
        position + 1,
        quill.BlockEmbed.image(imageUrl),
      );
      _quillController.document.insert(position + 2, '\n');
      _quillController.updateSelection(
        TextSelection.collapsed(offset: position + 3),
        quill.ChangeSource.local,
      );
      _updateTextController();
    } on Exception catch (e) {
      debugPrint('Error inserting image: $e');
    }
  }

  String getFormattedHtml() {
    try {
      final delta = _quillController.document.toDelta();
      final converter = QuillDeltaToHtmlConverter(
        delta.toJson(),
        ConverterOptions.forEmail(),
      );
      final html = converter.convert();

      return _postProcessHtml(html);
    } on Exception catch (e) {
      debugPrint('Error getting formatted HTML: $e');
      return _quillController.document.toPlainText();
    }
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
            showBackgroundColorButton: false,
            showAlignmentButtons: true,
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
            scrollable: widget.isCompact,
            autoFocus: true,
            expands: true,
            placeholder: widget.isCompact ? 'Nhập tiêu đề...' : 'Soạn thư',
            customStyles: quill.DefaultStyles(
              paragraph: quill.DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                const quill.VerticalSpacing(6, 0),
                const quill.VerticalSpacing(0, 0),
                null,
              ),
              h1: quill.DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey[200] : Colors.black87,
                ),
                const quill.VerticalSpacing(6, 0),
                const quill.VerticalSpacing(0, 0),
                null,
              ),
              h2: quill.DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.grey[200] : Colors.black87,
                ),
                const quill.VerticalSpacing(6, 0),
                const quill.VerticalSpacing(0, 0),
                null,
              ),
            ),
            embedBuilders: [ImageEmbedBuilder()],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quillController
      ..removeListener(_updateTextController)
      ..dispose();
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
