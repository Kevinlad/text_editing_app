// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../model/text_properties.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<List<TextProperties>> textPropertiesList = [[], [], []];
  String fontFamily = 'Arial';
  double fontSize = 20.0;
  Color fontColor = Colors.black;
  final TextEditingController _textEditingController = TextEditingController();
  final PageController _pageController = PageController();

  // History of changes for undo and redo
  List<List<List<TextProperties>>> history = [];
  int historyIndex = -1;

  @override
  void initState() {
    super.initState();
    // Initialize history with the initial state of textPropertiesList
    _addToHistory();
  }

  void _addToHistory() {
    // Clone textPropertiesList for history
    final List<List<TextProperties>> clonedTextPropertiesList =
        _cloneTextPropertiesList(textPropertiesList);
    history.add(clonedTextPropertiesList);
    historyIndex++;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        if (historyIndex > 0) {
          _undo();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Text On Images'),
          actions: [
            IconButton(onPressed: _undo, icon: const Icon(Icons.undo)),
            IconButton(onPressed: _redo, icon: const Icon(Icons.redo))
          ],
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: 3,
          itemBuilder: (context, index) {
            return buildPage(index);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showTextFieldDialog(context);
          },
          tooltip: 'Add Text',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget buildPage(int index) {
    return Stack(
      children: [
        Image.network(
          getImageUrl(index),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Stack(
          children: textPropertiesList[index].map((textProperty) {
            final textWidth =
                MediaQuery.of(context).size.width; // Get the device width
            final textSpan = TextSpan(
              text: textProperty.text,
              style: TextStyle(
                fontSize: textProperty.fontSize,
                fontFamily: textProperty.fontFamily,
              ),
            );
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            )..layout(
                minWidth: 0,
                maxWidth: textWidth); // Layout the text to calculate its width

            return Positioned(
              left: textProperty.position.dx.clamp(
                  0, MediaQuery.of(context).size.width - textPainter.width),
              top: textProperty.position.dy
                  .clamp(0, MediaQuery.of(context).size.height),
              child: GestureDetector(
                onTap: () {
                  _showTextPropertiesDialog(context, textProperty, index);
                },
                onPanUpdate: (details) {
                  setState(() {
                    // Adjust the text's position based on the delta value
                    final newLeft = textProperty.position.dx + details.delta.dx;
                    final newTop = textProperty.position.dy + details.delta.dy;

                    // Ensure that the new position remains within the screen bounds
                    final clampedLeft = newLeft.clamp(0,
                        MediaQuery.of(context).size.width - textPainter.width);
                    final clampedTop =
                        newTop.clamp(0, MediaQuery.of(context).size.height);

                    // Update the textProperty's position
                    textProperty.position =
                        Offset(clampedLeft.toDouble(), clampedTop.toDouble());
                  });
                },
                child: Text(
                  textProperty.text,
                  style: TextStyle(
                    fontSize: textProperty.fontSize,
                    color: textProperty.fontColor,
                    fontFamily: textProperty.fontFamily,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 2.6,
          left: 16.0,
          child: index != 0
              ? IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.black,
                )
              : const SizedBox(), // Empty SizedBox if on first page
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 2.6,
          right: 16.0,
          child: index != 2
              ? IconButton(
                  onPressed: () {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Colors.black,
                )
              : const SizedBox(), // Empty SizedBox if on last page
        ),
      ],
    );
  }

  String getImageUrl(int index) {
    // Replace with your image URLs
    if (index == 0) {
      return 'https://i.pinimg.com/736x/06/d0/34/06d034a64252a3e413e15e0e185645c8.jpg';
    } else if (index == 1) {
      return 'https://i.pinimg.com/736x/52/84/6d/52846d30603c7813de529b7c7b78ed6e.jpg';
    } else {
      return 'https://drevio.b-cdn.net/wp-content/uploads/2023/03/10-150-732x1024.jpg';
    }
  }

  void _showTextFieldDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Text'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(hintText: 'Enter text here'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _addText(
                    _textEditingController.text, _pageController.page!.toInt());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTextPropertiesDialog(
      BuildContext context, TextProperties textProperty, int pageIndex) {
    TextEditingController textEditingController =
        TextEditingController(text: textProperty.text);
    TextEditingController fontSizeController =
        TextEditingController(text: textProperty.fontSize.toString());
    Color selectedColor = textProperty.fontColor;
    String selectedFontFamily = textProperty.fontFamily;
    double selectedFontSize = textProperty.fontSize;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.28,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: textEditingController,
                decoration: const InputDecoration(labelText: 'Text'),
                onEditingComplete: () {
                  setState(() {
                    textProperty.text = textEditingController.text;
                    textPropertiesList[pageIndex].forEach(
                        (element) => element.text = textEditingController.text);
                    _addToHistory();
                    Navigator.of(context).pop();
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Font-Family:'),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedFontFamily,
                    iconSize: 20,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFontFamily = newValue!;
                        textProperty.fontFamily =
                            newValue; // Update property immediately
                        _addToHistory();
                      });
                    },
                    items: <String>[
                      'Arial',
                      'Roboto',
                      'Helvetica',
                      'Times New Roman',
                      'Courier New',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Font Size:'),
                      const SizedBox(width: 10),
                      DropdownButton<double>(
                        value: selectedFontSize,
                        onChanged: (double? newValue) {
                          setState(() {
                            selectedFontSize = newValue!;
                            textProperty.fontSize =
                                newValue; // Update property immediately
                            fontSizeController.text = newValue.toString();
                            _addToHistory();
                          });
                        },
                        items: <double>[
                          12.0,
                          14.0,
                          16.0,
                          18.0,
                          20.0,
                          24.0,
                          28.0,
                          32.0,
                          36.0,
                        ].map<DropdownMenuItem<double>>((double value) {
                          return DropdownMenuItem<double>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final Color? pickedColor = await _showColorPicker(
                            context,
                            selectedColor,
                          );
                          if (pickedColor != null) {
                            setState(() {
                              selectedColor = pickedColor;
                              textProperty.fontColor = pickedColor;
                              _addToHistory();
                            });
                          }
                        },
                        child: const Text('Pick Color'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Color?> _showColorPicker(
      BuildContext context, Color initialColor) async {
    return await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (Color color) {
                initialColor = color;
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(initialColor);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _addText(String text, int pageIndex) {
    double yPosition = 0.0;
    final screenHeight = MediaQuery.of(context).size.height;

    if (textPropertiesList[pageIndex].isNotEmpty) {
      final lastText = textPropertiesList[pageIndex].last;
      final textSize = lastText.fontSize;
      final lastYPosition = lastText.position.dy;
      final lastTextHeight = textSize;
      yPosition = lastYPosition + lastTextHeight + 20.0;
    } else {
      yPosition = 50.0;
    }

    // Limit the y-position to stay within the screen bounds
    yPosition = yPosition.clamp(0, screenHeight - 50);

    setState(() {
      // Clear future history when a new action is performed
      if (historyIndex < history.length - 1) {
        history.removeRange(historyIndex + 1, history.length);
      }

      // Clone textPropertiesList for history
      final List<List<TextProperties>> clonedTextPropertiesList =
          _cloneTextPropertiesList(textPropertiesList);
      history.add(clonedTextPropertiesList);
      historyIndex++;

      textPropertiesList[pageIndex].add(TextProperties(
        text: text,
        position: Offset(50.0, yPosition),
        fontFamily: fontFamily,
        fontSize: fontSize,
        fontColor: fontColor,
      ));
      _textEditingController.clear();
    });
  }

  void _undo() {
    if (historyIndex > 0) {
      setState(() {
        historyIndex--;
        textPropertiesList = _cloneTextPropertiesList(history[historyIndex]);
      });
    }
  }

  void _redo() {
    if (historyIndex < history.length - 1) {
      setState(() {
        historyIndex++;
        textPropertiesList = _cloneTextPropertiesList(history[historyIndex]);
      });
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<List<TextProperties>> _cloneTextPropertiesList(
      List<List<TextProperties>> list) {
    final List<List<TextProperties>> clonedList = [];
    for (final page in list) {
      final List<TextProperties> clonedPage = [];
      for (final textProperty in page) {
        clonedPage.add(textProperty
            .clone()); // Assuming you have a clone method in TextProperties
      }
      clonedList.add(clonedPage);
    }
    return clonedList;
  }
}
