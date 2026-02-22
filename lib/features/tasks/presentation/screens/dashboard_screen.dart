import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../task_bloc/task_bloc.dart';
import '../task_bloc/task_event.dart';
import '../task_bloc/task_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController taskController = TextEditingController();

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        title: const Text("My Tasks"),
        backgroundColor: const Color(0xFF5FB3A8),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          return Column(
            children: [
              /// 🔹 Add Task Field
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: taskController,
                        decoration: InputDecoration(
                          hintText: "Add new task...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5FB3A8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (taskController.text.trim().isNotEmpty) {
                          context.read<TaskBloc>().add(
                            AddTask(taskController.text.trim()),
                          );
                          taskController.clear();
                        }
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),

              /// 🔹 Task List
              Expanded(
                child: state.tasks.isEmpty
                    ? const Center(
                        child: Text(
                          "No tasks yet 👀",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.tasks.length,
                        itemBuilder: (context, index) {
                          final task = state.tasks[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: IconButton(
                                  icon: Icon(
                                    task.isCompleted
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: task.isCompleted
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    context.read<TaskBloc>().add(
                                      ToggleTask(task.id, task.isCompleted),
                                    );
                                  },
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    context.read<TaskBloc>().add(
                                      DeleteTask(task.id),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
