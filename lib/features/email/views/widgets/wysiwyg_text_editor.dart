import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WysiwygTextEditor extends StatefulWidget {
  const WysiwygTextEditor({
    required this.controller,
    required this.onClose,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onClose;

  @override
  State<WysiwygTextEditor> createState() => _WysiwygTextEditorState();
}

class _WysiwygTextEditorState extends State<WysiwygTextEditor> {
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  String selectedFont = 'Arial';
  double fontSize = 14.0;
  Color textColor = Colors.black;
  TextAlign textAlignment = TextAlign.left;
  final TextEditingController fontSizeController = TextEditingController();

  final List<String> fonts = [
    'Arial',
    'Times New Roman',
    'Helvetica',
    'Verdana',
    'Georgia',
    'Courier New',
  ];

  final List<Color> colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.brown,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    fontSizeController.text = fontSize.toInt().toString();
  }

  @override
  void dispose() {
    fontSizeController.dispose();
    super.dispose();
  }

  void _updateFontSize(String value) {
    double? newSize = double.tryParse(value);
    if (newSize != null && newSize >= 8 && newSize <= 72) {
      setState(() {
        fontSize = newSize;
      });
    } else {
      fontSizeController.text = fontSize.toInt().toString();
    }
  }

  void _incrementFontSize() {
    setState(() {
      if (fontSize < 72) {
        fontSize += 1;
        fontSizeController.text = fontSize.toInt().toString();
      }
    });
  }

  void _decrementFontSize() {
    setState(() {
      if (fontSize > 8) {
        fontSize -= 1;
        fontSizeController.text = fontSize.toInt().toString();
      }
    });
  }

  void _showColorPicker() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn màu chữ'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children:
                  colors.map((Color color) {
                    final isSelected = textColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() => textColor = color);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color:
                                      color == Colors.black ||
                                              color == Colors.brown
                                          ? Colors.white
                                          : Colors.black,
                                )
                                : null,
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? Colors.white24 : Colors.grey[300]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Định dạng văn bản',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Formatting toolbar
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildFormatButton(
                              icon: Icons.format_bold,
                              isSelected: isBold,
                              onPressed: () => setState(() => isBold = !isBold),
                              tooltip: 'In đậm',
                            ),
                            const SizedBox(width: 4),
                            _buildFormatButton(
                              icon: Icons.format_italic,
                              isSelected: isItalic,
                              onPressed:
                                  () => setState(() => isItalic = !isItalic),
                              tooltip: 'In nghiêng',
                            ),
                            const SizedBox(width: 4),
                            _buildFormatButton(
                              icon: Icons.format_underlined,
                              isSelected: isUnderline,
                              onPressed:
                                  () => setState(
                                    () => isUnderline = !isUnderline,
                                  ),
                              tooltip: 'Gạch chân',
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildFormatButton(
                              icon: Icons.format_align_left,
                              isSelected: textAlignment == TextAlign.left,
                              onPressed:
                                  () => setState(
                                    () => textAlignment = TextAlign.left,
                                  ),
                              tooltip: 'Căn trái',
                            ),
                            const SizedBox(width: 4),
                            _buildFormatButton(
                              icon: Icons.format_align_center,
                              isSelected: textAlignment == TextAlign.center,
                              onPressed:
                                  () => setState(
                                    () => textAlignment = TextAlign.center,
                                  ),
                              tooltip: 'Căn giữa',
                            ),
                            const SizedBox(width: 4),
                            _buildFormatButton(
                              icon: Icons.format_align_right,
                              isSelected: textAlignment == TextAlign.right,
                              onPressed:
                                  () => setState(
                                    () => textAlignment = TextAlign.right,
                                  ),
                              tooltip: 'Căn phải',
                            ),
                            const SizedBox(width: 4),
                            _buildFormatButton(
                              icon: Icons.format_align_justify,
                              isSelected: textAlignment == TextAlign.justify,
                              onPressed:
                                  () => setState(
                                    () => textAlignment = TextAlign.justify,
                                  ),
                              tooltip: 'Căn đều',
                            ),
                            const SizedBox(width: 4),
                            _buildFormatButton(
                              icon: Icons.color_lens,
                              isSelected: false,
                              onPressed: _showColorPicker,
                              tooltip: 'Chọn màu chữ',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Font and size row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildFontDropdown(isDarkMode),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _buildFontSizeInput(isDarkMode)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Áp dụng', style: TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? (isDarkMode ? Colors.blue[800] : Colors.blue[100])
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDarkMode ? Colors.white24 : Colors.grey[300]!,
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
                isSelected
                    ? (isDarkMode ? Colors.blue[300] : Colors.blue[800])
                    : (isDarkMode ? Colors.white70 : Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildFontDropdown(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? Colors.white24 : Colors.grey[300]!,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFont,
          isExpanded: true,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 12,
          ),
          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
          items:
              fonts.map((String font) {
                return DropdownMenuItem<String>(
                  value: font,
                  child: Text(
                    font,
                    style: TextStyle(fontFamily: font, fontSize: 12),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedFont = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildFontSizeInput(bool isDarkMode) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.remove,
            size: 12,
            color: isDarkMode ? Colors.white70 : Colors.grey[700],
          ),
          onPressed: _decrementFontSize,
          tooltip: 'Giảm cỡ chữ',
          padding: EdgeInsets.zero,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDarkMode ? Colors.white24 : Colors.grey[300]!,
                width: 0.5,
              ),
            ),
            child: TextField(
              controller: fontSizeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 12,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: _updateFontSize,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add,
            size: 12,
            color: isDarkMode ? Colors.white70 : Colors.grey[700],
          ),
          onPressed: _incrementFontSize,
          tooltip: 'Tăng cỡ chữ',
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
