import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_tracker/models/task_model.dart';
import 'package:workspace_tracker/providers/project_provider.dart';
import 'package:workspace_tracker/providers/task_provider.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().fetchProjectById(widget.projectId);
      context.read<TaskProvider>().fetchProjectTasks(widget.projectId);
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0f172a),
        title: const Text(
          'Add New Task',
          style: TextStyle(color: Color(0xFFf1f5f9)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                labelStyle: const TextStyle(color: Color(0xFF94a3b8)),
                filled: true,
                fillColor: const Color(0xFF0f1422),
                border: OutlineInputBorder(
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
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Task title is required'),
                    backgroundColor: Colors.red.shade400,
                  ),
                );
                return;
              }

              final taskProvider = context.read<TaskProvider>();
              final success = await taskProvider.createTask(
                title: titleController.text,
                description: descController.text,
                projectId: widget.projectId,
              );

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Task created successfully'),
                      backgroundColor: Colors.green.shade400,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(taskProvider.errorMessage ?? 'Failed to create task'),
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

  void _showTaskDetailsDialog(BuildContext context, TaskItem task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    var selectedStatus = task.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF0f172a),
          title: const Text(
            'Task Details',
            style: TextStyle(color: Color(0xFFf1f5f9)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    labelStyle: const TextStyle(color: Color(0xFF94a3b8)),
                    filled: true,
                    fillColor: const Color(0xFF0f1422),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF1e293b)),
                    ),
                  ),
                  style: const TextStyle(color: Color(0xFFf1f5f9)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Status',
                  style: TextStyle(
                    color: Color(0xFF94a3b8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButton<TaskStatus>(
                  value: selectedStatus,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF0f1422),
                  items: TaskStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.value,
                        style: const TextStyle(color: Color(0xFFf1f5f9)),
                      ),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    setState(() {
                      selectedStatus = newStatus!;
                    });
                  },
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
                  ),
                  style: const TextStyle(color: Color(0xFFf1f5f9)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final taskProvider = context.read<TaskProvider>();
                final success = await taskProvider.deleteTask(task.id);

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Task deleted successfully'),
                        backgroundColor: Colors.green.shade400,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(taskProvider.errorMessage ?? 'Failed to delete task'),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF94a3b8)),
              ),
            ),
            TextButton(
              onPressed: () async {
                final taskProvider = context.read<TaskProvider>();
                final success = await taskProvider.updateTask(
                  id: task.id,
                  title: titleController.text,
                  description: descController.text,
                  status: selectedStatus,
                  projectId: widget.projectId,
                );

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Task updated successfully'),
                        backgroundColor: Colors.green.shade400,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(taskProvider.errorMessage ?? 'Failed to update task'),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ],
        ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFf1f5f9)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<ProjectProvider>(
          builder: (context, projectProvider, _) {
            final project = projectProvider.selectedProject;
            return Text(
              project?.name ?? 'Project Details',
              style: const TextStyle(
                color: Color(0xFFf1f5f9),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade600,
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer2<ProjectProvider, TaskProvider>(
        builder: (context, projectProvider, taskProvider, _) {
          if (projectProvider.isLoading || taskProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.indigo),
              ),
            );
          }

          final project = projectProvider.selectedProject;
          if (project == null) {
            return const Center(
              child: Text(
                'Project not found',
                style: TextStyle(color: Color(0xFF94a3b8)),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Info
                Card(
                  color: const Color(0xFF0f172a),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFF1e293b)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            color: Color(0xFFf1f5f9),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.description.isEmpty
                              ? 'No description provided'
                              : project.description,
                          style: const TextStyle(
                            color: Color(0xFF94a3b8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Tasks Section
                const Text(
                  'Tasks',
                  style: TextStyle(
                    color: Color(0xFFf1f5f9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                if (taskProvider.tasks.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 48,
                            color: Colors.indigo.shade400.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Tasks Yet',
                            style: TextStyle(
                              color: Color(0xFFf1f5f9),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add a task to get started',
                            style: TextStyle(
                              color: Color(0xFF94a3b8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];
                      final statusColor = task.status == TaskStatus.todo
                          ? Colors.orange.shade400
                          : task.status == TaskStatus.inProgress
                              ? Colors.blue.shade400
                              : Colors.green.shade400;

                      return GestureDetector(
                        onTap: () => _showTaskDetailsDialog(context, task),
                        child: Card(
                          color: const Color(0xFF0f172a),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFF1e293b)),
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: const TextStyle(
                                          color: Color(0xFFf1f5f9),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        border: Border.all(color: statusColor),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        task.status.value,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (task.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    task.description,
                                    style: const TextStyle(
                                      color: Color(0xFF94a3b8),
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  'Created ${task.createdAt.toString().split(' ')[0]}',
                                  style: const TextStyle(
                                    color: Color(0xFF64748b),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
