import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/network/connectivity_cubit.dart';
import 'package:task_manager/features/tasks/presentation/screens/add_task_screen.dart';
import 'package:task_manager/features/theme/theme_cubit.dart';
import '../task_bloc/task_bloc.dart';
import '../task_bloc/task_event.dart';
import '../task_bloc/task_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      context.read<TaskBloc>().add(LoadTasks(user.uid));
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        context.read<TaskBloc>().add(LoadMoreTasks());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<ConnectivityCubit, bool>(
      listener: (context, isOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOnline ? "✅ Back online" : "⚠️ You are offline"),
            backgroundColor: isOnline ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.brightness_6,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
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
        body: SafeArea(
          child: Column(
            children: [
              /// SEARCH
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "search by title",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          context.read<TaskBloc>().add(SearchTask(value));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort),
                      onSelected: (value) {
                        context.read<TaskBloc>().add(SortTasks(value));
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: "dueDate",
                          child: Text("Due Date"),
                        ),
                        PopupMenuItem(
                          value: "priority",
                          child: Text("Priority"),
                        ),
                        PopupMenuItem(
                          value: "createdAt",
                          child: Text("Created Date"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// FILTER
              _buildControls(),

              /// TASK LIST
              Expanded(
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    if (state.status == TaskStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == TaskStatus.error) {
                      return const Center(child: Text("Failed to load tasks"));
                    }

                    if (state.tasks.isEmpty) {
                      return const Center(
                        child: Text(
                          "No tasks yet",
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<TaskBloc>().add(RefreshTasks());
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            state.tasks.length + (state.hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index >= state.tasks.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final task = state.tasks[index];

                          return Dismissible(
                            key: ValueKey(task.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              context.read<TaskBloc>().add(DeleteTask(task.id));
                            },
                            child: ListTile(
                              title: Text(task.title),
                              subtitle: Text(
                                "Priority: ${task.priority} | Due: ${task.dueDate.toLocal().toString().split(' ')[0]}",
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  task.isCompleted
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                ),
                                color: task.isCompleted
                                    ? Colors.green
                                    : Colors.grey,
                                onPressed: () {
                                  context.read<TaskBloc>().add(
                                    ToggleTaskStatus(
                                      taskId: task.id,
                                      isCompleted: !task.isCompleted,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTaskScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          final tasks = state.allTasks;
          final completed = tasks.where((t) => t.isCompleted).length;
          final pending = tasks.length - completed;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterChip(
                label: Text("All (${tasks.length})"),
                selected: state.filter == "all",
                onSelected: (_) {
                  context.read<TaskBloc>().add(ApplyFilter("all"));
                },
              ),
              FilterChip(
                label: Text("Completed ($completed)"),
                selected: state.filter == "completed",
                onSelected: (_) {
                  context.read<TaskBloc>().add(ApplyFilter("completed"));
                },
              ),
              FilterChip(
                label: Text("Pending ($pending)"),
                selected: state.filter == "pending",
                onSelected: (_) {
                  context.read<TaskBloc>().add(ApplyFilter("pending"));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
