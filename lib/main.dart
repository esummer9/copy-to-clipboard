import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Copy2Clipboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Copy2Clipboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _leftListItems = [];
  final List<Color> _leftItemColors = []; // To store colors for left list items
  final List<String> _rightListItems = [];
  final List<Color> _rightItemColors = []; // To store colors for right list items
  String? _initialClipboardContent;

  @override
  void initState() {
    super.initState();
    _loadInitialClipboardContent();
  }

  Future<void> _loadInitialClipboardContent() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    setState(() {
      _initialClipboardContent = clipboardData?.text;
    });
  }

  Future<void> _copyToInitialClipboardContent() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    setState(() {
      _initialClipboardContent = clipboardData?.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Current clipboard content copied to initial variable!')),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _leftListItems.clear();
        _leftItemColors.clear(); // Clear colors as well
        final items = clipboardData.text!.split('\n').where((item) => item.isNotEmpty).toList();
        _leftListItems.addAll(items);
        // Initialize colors to default for new items
        for (int i = 0; i < items.length; i++) {
          _leftItemColors.add(Theme.of(context).cardColor);
        }
      });
    }
  }

  void _copyAndHighlightLeftItem(int index) {
    final textToCopy = _leftListItems[index];
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied "$textToCopy" to clipboard!')),
    );

    setState(() {
      // Reset all colors to default first, then highlight the clicked one
      for (int i = 0; i < _leftItemColors.length; i++) {
        _leftItemColors[i] = Theme.of(context).cardColor;
      }
      _leftItemColors[index] = Colors.yellow;

      // Append to right list
      _rightListItems.add(textToCopy);
      _rightItemColors.add(Theme.of(context).cardColor); // Add default color for new item
    });
  }

  void _clearRightList() {
    setState(() {
      _rightListItems.clear();
      _rightItemColors.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Right list cleared!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Row(
        children: <Widget>[
          // Left side
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _copyToInitialClipboardContent,
                    child: const Text('Clipboard to buffer'),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: _pasteFromClipboard, // This button now pastes from actual clipboard to left list
                    child: const Text('Paste from buffer'),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _leftListItems.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: _leftItemColors[index], // Use the color from the list
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: InkWell(
                            onTap: () => _copyAndHighlightLeftItem(index),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(_leftListItems[index]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1.0),
          // Right side
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _clearRightList,
                    child: const Text('Clear Right List'),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _rightListItems.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: _rightItemColors[index], // Use the color from the list
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(_rightListItems[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
