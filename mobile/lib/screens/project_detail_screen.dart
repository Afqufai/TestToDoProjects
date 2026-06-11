import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workspace_tracker/models/task_model.dart';
import 'package:workspace_tracker/providers/project_provider.dart';
import 'package:workspace_tracker/providers/task_provider.dart';
import 'package:workspace_tracker/utils/ui_helpers.dart';

/// Screen displaying the details of a project and its tasks.
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().fetchProjectById(widget.projectId);
      context.read<ProjectProvider>().fetchProjectAnalytics(widget.projectId);
      context.read<TaskProvider>().fetchProjectTasks(widget.projectId);
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Add New Task',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: buildInputDecoration(labelText: 'Task Title'),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: buildInputDecoration(labelText: 'Description'),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                showAppSnackBar(
                  context,
                  message: 'Task title is required',
                  color: AppColors.error,
                );
                return;
              }

              final taskProvider = context.read<TaskProvider>();
              final success = await taskProvider.createTask(
                title: titleController.text,
                description: descController.text,
                projectId: widget.projectId,
              );

              if (!context.mounted) return;
              Navigator.pop(context);
              if (success) {
                context.read<ProjectProvider>().fetchProjectAnalytics(widget.projectId);
                showAppSnackBar(
                  context,
                  message: 'Task created successfully',
                  color: AppColors.success,
                );
              } else {
                showAppSnackBar(
                  context,
                  message: taskProvider.errorMessage ?? 'Failed to create task',
                  color: AppColors.error,
                );
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
          backgroundColor: AppColors.surface,
          title: const Text(
            'Task Details',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: buildInputDecoration(labelText: 'Task Title'),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Status',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskStatus>(
                  initialValue: selectedStatus,
                  isExpanded: true,
                  dropdownColor: AppColors.inputFill,
                  decoration: buildInputDecoration(labelText: 'Current Status'),
                  items: TaskStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.value,
                        style: const TextStyle(color: AppColors.textPrimary),
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
                  decoration: buildInputDecoration(labelText: 'Description'),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final taskProvider = context.read<TaskProvider>();
                final success = await taskProvider.deleteTask(task.id);

                if (!context.mounted) return;
                Navigator.pop(context);
                if (success) {
                  context.read<ProjectProvider>().fetchProjectAnalytics(widget.projectId);
                  showAppSnackBar(
                    context,
                    message: 'Task deleted successfully',
                    color: AppColors.success,
                  );
                } else {
                  showAppSnackBar(
                    context,
                    message: taskProvider.errorMessage ?? 'Failed to delete task',
                    color: AppColors.error,
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
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

                if (!context.mounted) return;
                Navigator.pop(context);
                if (success) {
                  context.read<ProjectProvider>().fetchProjectAnalytics(widget.projectId);
                  showAppSnackBar(
                    context,
                    message: 'Task updated successfully',
                    color: AppColors.success,
                  );
                } else {
                  showAppSnackBar(
                    context,
                    message: taskProvider.errorMessage ?? 'Failed to update task',
                    color: AppColors.error,
                  );
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<ProjectProvider>(
          builder: (context, projectProvider, _) {
            final project = projectProvider.selectedProject;
            return Text(
              project?.name ?? 'Project Details',
              style: const TextStyle(
                color: AppColors.textPrimary,
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
                style: TextStyle(color: AppColors.textSecondary),
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
                  color: AppColors.surface,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
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
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Project Analytics Dashboard
                _buildAnalyticsWidget(projectProvider),

                const SizedBox(height: 24),

                // Tasks Section
                const Text(
                  'Tasks',
                  style: TextStyle(
                    color: AppColors.textPrimary,
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
                            color: Colors.indigo.shade400.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Tasks Yet',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add a task to get started',
                            style: TextStyle(
                              color: AppColors.textSecondary,
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
                          color: AppColors.surface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.border),
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
                                          color: AppColors.textPrimary,
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
                                        color: statusColor.withValues(alpha: 0.2),
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
                                      color: AppColors.textSecondary,
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
                                    color: AppColors.textTertiary,
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

  Widget _buildAnalyticsWidget(ProjectProvider provider) {
    if (provider.isAnalyticsLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.indigo),
          ),
        ),
      );
    }

    final analytics = provider.projectAnalytics;
    if (analytics == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Health',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Progress Bar Card
        Card(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Completion Progress',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${analytics.completionPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: analytics.totalTasks == 0 ? 0 : analytics.completionPercentage / 100,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigoAccent),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Stats Row
        Row(
          children: [
            _buildStatCard('Total Tasks', analytics.totalTasks.toString(), Colors.indigoAccent),
            const SizedBox(width: 12),
            _buildStatCard('Completed', analytics.completedTasks.toString(), Colors.green),
            const SizedBox(width: 12),
            _buildStatCard('Bottlenecks', analytics.bottleneckTasks.toString(), Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
