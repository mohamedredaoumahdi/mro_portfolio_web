// lib/views/admin/services/services_manager.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_website/models/project_model.dart';
import 'package:portfolio_website/services/firestore_service.dart';
import 'package:portfolio_website/viewmodels/service_viewmodel.dart';

class ServicesManagerScreen extends StatefulWidget {
  const ServicesManagerScreen({Key? key}) : super(key: key);

  @override
  State<ServicesManagerScreen> createState() => _ServicesManagerScreenState();
}

class _ServicesManagerScreenState extends State<ServicesManagerScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  Service? _selectedService;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Services Manager',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                ElevatedButton.icon(
                  onPressed: () => _showServiceForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Service'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Create and manage services for your portfolio',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            
            // Services list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildServicesList(context),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildServicesList(BuildContext context) {
    return Consumer<ServiceViewModel>(
      builder: (context, serviceViewModel, child) {
        if (serviceViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (serviceViewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading services',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(serviceViewModel.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => serviceViewModel.loadServices(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (serviceViewModel.services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.design_services, color: Colors.grey, size: 48),
                const SizedBox(height: 16),
                Text(
                  'No services found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('Add your first service using the button above'),
              ],
            ),
          );
        }
        
        return ReorderableListView.builder(
          itemCount: serviceViewModel.services.length,
          onReorder: (oldIndex, newIndex) {
            // Handle reordering
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            // TODO: Implement reordering logic to update the database
          },
          itemBuilder: (context, index) {
            final service = serviceViewModel.services[index];
            return Card(
              key: Key(service.id),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Service icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getIconData(service.iconPath),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Service details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Action buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _selectedService = service;
                            _showServiceForm(context, isEditing: true);
                          },
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(context, service),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  IconData _getIconData(String iconName) {
    // Map string icon names to IconData
    // Using Material Icons to avoid storage costs
    switch (iconName) {
      case 'phone_android':
        return Icons.phone_android;
      case 'design_services':
        return Icons.design_services;
      case 'api':
        return Icons.api;
      case 'build':
        return Icons.build;
      case 'code':
        return Icons.code;
      case 'integration_instructions':
        return Icons.integration_instructions;
      case 'web':
        return Icons.web;
      case 'devices':
        return Icons.devices;
      default:
        return Icons.code; // Default icon
    }
  }
  
  void _showServiceForm(BuildContext context, {bool isEditing = false}) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(
        service: isEditing ? _selectedService : null,
        onSave: () {
          Navigator.pop(context);
          // Refresh the services list
          context.read<ServiceViewModel>().loadServices();
        },
      ),
    ).then((_) {
      // Clear selected service after dialog is closed
      setState(() {
        _selectedService = null;
      });
    });
  }
  
  void _showDeleteConfirmation(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              
              try {
                // Delete the service from Firestore
                await FirestoreService().deleteService(service.id);
                
                // Refresh the services list
                if (mounted) {
                  context.read<ServiceViewModel>().loadServices();
                }
              } catch (e) {
                setState(() {
                  _errorMessage = 'Failed to delete service: ${e.toString()}';
                  _isLoading = false;
                });
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class ServiceFormDialog extends StatefulWidget {
  final Service? service;
  final VoidCallback onSave;

  const ServiceFormDialog({
    Key? key,
    this.service,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedIcon = 'code';
  bool _isLoading = false;
  String? _errorMessage;
  
  // List of available icon options
  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'code', 'icon': Icons.code, 'label': 'Code'},
    {'name': 'phone_android', 'icon': Icons.phone_android, 'label': 'Mobile'},
    {'name': 'design_services', 'icon': Icons.design_services, 'label': 'Design'},
    {'name': 'api', 'icon': Icons.api, 'label': 'API'},
    {'name': 'build', 'icon': Icons.build, 'label': 'Build'},
    {'name': 'integration_instructions', 'icon': Icons.integration_instructions, 'label': 'Integration'},
    {'name': 'web', 'icon': Icons.web, 'label': 'Web'},
    {'name': 'devices', 'icon': Icons.devices, 'label': 'Devices'},
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize form with existing service data if editing
    if (widget.service != null) {
      _titleController.text = widget.service!.title;
      _descriptionController.text = widget.service!.description;
      _selectedIcon = widget.service!.iconPath.isEmpty ? 'code' : widget.service!.iconPath;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.service != null;
    
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog title
                Text(
                  isEditing ? 'Edit Service' : 'Add New Service',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                
                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Service Title',
                            hintText: 'Enter service title',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Description field
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Service Description',
                            hintText: 'Enter service description',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Icon selection
                        const Text(
                          'Select an Icon',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: _iconOptions.map((option) {
                            final bool isSelected = _selectedIcon == option['name'];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedIcon = option['name'] as String;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 80,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      option['icon'] as IconData,
                                      color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).iconTheme.color,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      option['label'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveService,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Update' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _saveService() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final firestoreService = FirestoreService();
        
        final serviceData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'iconName': _selectedIcon,
        };
        
        if (widget.service != null) {
          // Update existing service
          await firestoreService.updateService(widget.service!.id, serviceData);
        } else {
          // Create new service
          await firestoreService.addService(serviceData);
        }
        
        // Call onSave callback
        widget.onSave();
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to save service: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
}