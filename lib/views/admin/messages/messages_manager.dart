// lib/views/admin/messages/messages_manager.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:portfolio_website/services/firestore_service.dart';
import 'package:portfolio_website/viewmodels/activity_viewmodel.dart';
import 'package:provider/provider.dart';

class MessagesManagerScreen extends StatefulWidget {
  const MessagesManagerScreen({super.key});

  @override
  State<MessagesManagerScreen> createState() => _MessagesManagerScreenState();
}

class _MessagesManagerScreenState extends State<MessagesManagerScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _selectedMessage;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final firestoreService = FirestoreService.instance;
      final messages = await firestoreService.getContactSubmissions();
      
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load messages: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Messages',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage contact form submissions',
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
            
            // Messages content
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMessagesContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesContent() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            Text(
              'No messages found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text('When someone contacts you, messages will appear here'),
          ],
        ),
      );
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Messages list (left side)
        Expanded(
          flex: 2,
          child: Card(
            elevation: 1,
            child: ListView.separated(
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final message = _messages[index];
                final timestamp = message['timestamp'] as Timestamp?;
                final formattedDate = timestamp != null 
                  ? DateFormat('MMM d, yyyy • h:mm a').format(timestamp.toDate())
                  : 'Unknown date';
                
                final isSelected = _selectedMessage != null && 
                                 _selectedMessage!['id'] == message['id'];
                
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade200,
                    child: Icon(
                      Icons.person,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                  title: Text(
                    message['name'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['subject'] ?? 'No subject',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedMessage = message;
                    });
                  },
                );
              },
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Message detail (right side)
        Expanded(
          flex: 3,
          child: _selectedMessage != null
            ? _buildMessageDetail()
            : const Center(
                child: Text('Select a message to view details'),
              ),
        ),
      ],
    );
  }

  Widget _buildMessageDetail() {
    if (_selectedMessage == null) return const SizedBox.shrink();
    
    final message = _selectedMessage!;
    final timestamp = message['timestamp'] as Timestamp?;
    final date = timestamp != null 
      ? DateFormat('MMMM d, yyyy • h:mm a').format(timestamp.toDate())
      : 'Unknown date';
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(message),
                    ),
                    IconButton(
                      icon: const Icon(Icons.reply),
                      tooltip: 'Reply',
                      onPressed: () => _replyToMessage(message),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            
            // From
            const SizedBox(height: 16),
            Text(
              'From:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    (message['name'] as String?)?.isNotEmpty == true
                      ? (message['name'] as String).characters.first.toUpperCase()
                      : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      message['email'] ?? 'No email',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Subject
            const SizedBox(height: 24),
            Text(
              'Subject:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['subject'] ?? 'No subject',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            
            // Message content
            const SizedBox(height: 24),
            Text(
              'Message:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    message['message'] ?? 'No message content',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: Text('Are you sure you want to delete this message from ${message['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Log activity
                final activityViewModel = Provider.of<ActivityViewModel>(context, listen: false);
                await activityViewModel.logActivity(
                  type: 'delete',
                  message: 'You deleted a message from "${message['name']}"',
                  entityId: message['id'],
                  metadata: {'name': message['name'], 'type': 'contact_message'},
                );
                
                // Delete from Firestore
                await FirebaseFirestore.instance
                    .collection('contact_submissions')
                    .doc(message['id'])
                    .delete();
                
                // Refresh the list
                await _loadMessages();
                
                // Clear selection if deleted
                if (_selectedMessage != null && _selectedMessage!['id'] == message['id']) {
                  setState(() {
                    _selectedMessage = null;
                  });
                }
                
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting message: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _replyToMessage(Map<String, dynamic> message) {
    final email = message['email'];
    if (email == null || email.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email address found to reply to')),
      );
      return;
    }
    
    // Create a mailto link
    final subject = 'RE: ${message['subject'] ?? 'Your message'}';
    final body = 'Hello ${message['name']},\n\nThank you for reaching out...\n\n';
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    
    // Launch email client
    launchUrl(uri);
  }
}

Future<bool> launchUrl(Uri uri) async {
  // In a real app, you would use url_launcher package
  // For now, just print and return true
  print('Launching URL: $uri');
  return true;
}