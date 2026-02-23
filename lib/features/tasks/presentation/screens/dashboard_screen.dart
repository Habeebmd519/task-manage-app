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

    debugPrint("Dashboard opened");
    debugPrint("Current user UID: ${user?.uid}");

    if (user != null) {
      debugPrint("Dispatching LoadTasks event");
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
    return Scaffold(
      // backgroundColor: const Color(0xFFF5F7F6),
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
      body: Column(
        children: [
          /// 🔍 SEARCH
          Row(
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    context.read<TaskBloc>().add(SearchTask(value));
                  },
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5FB3A8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.sort, color: Colors.white),
                    onSelected: (value) {
                      context.read<TaskBloc>().add(SortTasks(value));
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: "dueDate", child: Text("Due Date")),
                      PopupMenuItem(value: "priority", child: Text("Priority")),
                      PopupMenuItem(
                        value: "createdAt",
                        child: Text("Created Date"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          /// 🎛 FILTER + SORT
          _buildControls(),

          /// 📋 TASK LIST
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state.status == TaskStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == TaskStatus.error) {
                  return const Center(child: Text("Failed to load tasks"));
                }

                /// ⭐ ADD THIS
                if (state.tasks.isEmpty) {
                  return const Center(
                    child: Text("No tasks yet", style: TextStyle(fontSize: 18)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    debugPrint("Refreshing tasks...");
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
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          debugPrint("Deleting task: ${task.id}");
                          context.read<TaskBloc>().add(DeleteTask(task.id));
                        },
                        confirmDismiss: (_) async {
                          return true;
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
                              debugPrint("Toggle task: ${task.id}");
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
          BlocListener<ConnectivityCubit, bool>(
            listener: (context, isOnline) {
              if (!isOnline) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("⚠️ You are offline"),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Back online"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Scaffold(
              // your existing scaffold
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
      ),
    );
  }

  /// 🎛 Filter + Sort Row
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Expanded(
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
      ),
    );
  }
}
