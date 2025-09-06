import 'package:flutter/material.dart';

import '../models/device_model.dart';

class DeviceSelectionScreen extends StatefulWidget {
  final List<DeviceModel> devices;
  final int? selectedDeviceId;
  final Function(int) onDeviceSelected;

  const DeviceSelectionScreen({
    super.key,
    required this.devices,
    required this.onDeviceSelected,
    this.selectedDeviceId,
  });

  @override
  State<DeviceSelectionScreen> createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  int? _selectedDeviceId;

  @override
  void initState() {
    super.initState();
    _selectedDeviceId = widget.selectedDeviceId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF036CA0),
      appBar: AppBar(
        backgroundColor: Color(0xFF036CA0),
        title: const Text(
          'Select Device Type',
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
              childAspectRatio: 0.9, // Similar to sweat image selection
            ),
            itemCount: widget.devices.length,
            itemBuilder: (context, index) {
              final device = widget.devices[index];
              final isSelected = _selectedDeviceId == device.id;

              // Determine which image to show based on device name
              String? imagePath;
              if (device.deviceName.toLowerCase().contains('classic') ||
                  device.deviceName.toLowerCase().contains('plus')) {
                imagePath = 'assets/images/classic_plus.png';
              }
              if (device.deviceName.toLowerCase().contains('pro') ||
                  device.deviceName.toLowerCase().contains('pro plus')) {
                imagePath = 'assets/images/pro_plus.png';
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDeviceId = device.id;
                  });

                  // Call the callback with selected device ID
                  widget.onDeviceSelected(device.id);

                  // Navigate back to test screen
                  Navigator.of(context).pop();

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected: ${device.deviceName}'),
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
                        flex: 3, // Give more space to image
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(9),
                          ),
                          child: Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: imagePath != null
                                ? Image.asset(
                                    imagePath,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                  )
                                : const Icon(
                                    Icons.device_hub,
                                    color: Colors.grey,
                                    size: 60,
                                  ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1, // Less space for text
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
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
                                  device.deviceName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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
