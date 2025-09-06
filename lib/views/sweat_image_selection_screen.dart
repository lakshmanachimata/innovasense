import 'package:flutter/material.dart';
import '../models/sweat_image_model.dart';

class SweatImageSelectionScreen extends StatefulWidget {
  final List<SweatImageModel> sweatImages;
  final int? selectedImageId;
  final Function(int) onImageSelected;

  const SweatImageSelectionScreen({
    super.key,
    required this.sweatImages,
    required this.onImageSelected,
    this.selectedImageId,
  });

  @override
  State<SweatImageSelectionScreen> createState() => _SweatImageSelectionScreenState();
}

class _SweatImageSelectionScreenState extends State<SweatImageSelectionScreen> {
  int? _selectedImageId;

  @override
  void initState() {
    super.initState();
    _selectedImageId = widget.selectedImageId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF036CA0),
      appBar: AppBar(
        backgroundColor: Color(0xFF036CA0),
        title: const Text(
          'Select Sweat Level',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4 // Further reduced to give more space for text area
            ),
            itemCount: widget.sweatImages.length,
          itemBuilder: (context, index) {
            final sweatImage = widget.sweatImages[index];
            final isSelected = _selectedImageId == sweatImage.id;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImageId = sweatImage.id;
                });
                
                // Call the callback with selected image ID
                widget.onImageSelected(sweatImage.id);
                
                // Navigate back to test screen
                Navigator.of(context).pop();
                
                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected: ${sweatImage.result}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.white,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 6, // Give more space to image
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(9),
                        ),
                        child: Image.network(
                          sweatImage.imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: const Icon(
                                Icons.error,
                                color: Colors.white,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1, // Less space for text
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF036CA0),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(9),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                sweatImage.result,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // if (sweatImage.sweatRange.isNotEmpty)
                            //   Flexible(
                            //     child: Text(
                            //       sweatImage.sweatRange,
                            //       style: const TextStyle(
                            //         color: Colors.white70,
                            //         fontSize: 9,
                            //       ),
                            //       textAlign: TextAlign.center,
                            //       maxLines: 1,
                            //       overflow: TextOverflow.ellipsis,
                            //     ),
                            //   ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          ),
        ),
      ),
    );
  }
}
