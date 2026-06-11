import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_tracker/providers/auth_provider.dart';
import 'package:workspace_tracker/providers/project_provider.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({Key? key}) : super(key: key);

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().fetchProjects();
    });
  }

  void _showAddProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0f172a),
        title: const Text(
          'Create New Project',
          style: TextStyle(color: Color(0xFFf1f5f9)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Project Name',
                labelStyle: const TextStyle(color: Color(0xFF94a3b8)),
                filled: true,
                fillColor: const Color(0xFF0f1422),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1e293b)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1e293b)),
                ),
              ),
              style: const TextStyle(color: Color(0xFFf1f5f9)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: Color(0xFF94a3b8)),
                filled: true,
                fillColor: const Color(0xFF0f1422),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1e293b)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1e293b)),
                ),
              ),
              style: const TextStyle(color: Color(0xFFf1f5f9)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF94a3b8)),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Project name is required'),
                    backgroundColor: Colors.red.shade400,
                  ),
                );
                return;
              }

              final projectProvider = context.read<ProjectProvider>();
              final success = await projectProvider.createProject(
                name: nameController.text,
                description: descController.text,
              );

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Project created successfully'),
                      backgroundColor: Colors.green.shade400,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(projectProvider.errorMessage ?? 'Failed to create project'),
                      backgroundColor: Colors.red.shade400,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(color: Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF030712),
        elevation: 0,
        title: const Text(
          'Your Projects',
          style: TextStyle(
            color: Color(0xFFf1f5f9),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) => GestureDetector(
                  onTap: () async {
                    await authProvider.logout();
                    if (mounted) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color(0xFF94a3b8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade600,
        onPressed: () => _showAddProjectDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, _) {
          if (projectProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.indigo),
              ),
            );
          }

          if (projectProvider.projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 48,
                    color: Colors.indigo.shade400.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Projects Yet',
                    style: TextStyle(
                      color: Color(0xFFf1f5f9),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first project to get started',
                    style: TextStyle(
                      color: Color(0xFF94a3b8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddProjectDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Project'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projectProvider.projects.length,
            itemBuilder: (context, index) {
              final project = projectProvider.projects[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/project-detail',
                    arguments: project.id,
                  );
                },
                child: Card(
                  color: const Color(0xFF0f172a),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF1e293b)),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            color: Color(0xFFf1f5f9),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.description.isEmpty
                              ? 'No description'
                              : project.description,
                          style: const TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Created ${project.createdAt.toString().split(' ')[0]}',
                          style: const TextStyle(
                            color: Color(0xFF64748b),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
