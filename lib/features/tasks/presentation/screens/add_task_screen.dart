import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../task_bloc/task_bloc.dart';
import '../task_bloc/task_event.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();

  String _priority = "Medium";
  String _category = "Work";
  DateTime? _dueDate;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  void _submit() {
    if (_titleController.text.isEmpty || _dueDate == null) return;

    context.read<TaskBloc>().add(
      CreateTask(
        title: _titleController.text,
        priority: _priority,
        dueDate: _dueDate!,
        category: _category,
      ),
    );
    debugPrint("Creating task: ${_titleController.text}");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Task"),
        backgroundColor: const Color(0xFF5FB3A8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TITLE
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Task title"),
            ),

            const SizedBox(height: 10),

            /// PRIORITY
            DropdownButtonFormField<String>(
              key: ValueKey(_priority),
              initialValue: _priority,
              items: const [
                DropdownMenuItem(value: "High", child: Text("High")),
                DropdownMenuItem(value: "Medium", child: Text("Medium")),
                DropdownMenuItem(value: "Low", child: Text("Low")),
              ],
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
            ),

            const SizedBox(height: 10),

            /// CATEGORY
            DropdownButtonFormField<String>(
              key: ValueKey(_category),
              initialValue: _category,
              items: const [
                DropdownMenuItem(value: "Work", child: Text("Work")),
                DropdownMenuItem(value: "Personal", child: Text("Personal")),
              ],
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
              decoration: const InputDecoration(labelText: "Category"),
            ),

            const SizedBox(height: 10),

            /// DATE
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? "Pick due date"
                        : _dueDate.toString().split(" ")[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text("Select"),
                ),
              ],
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _submit,
              child: const Text("Create Task"),
            ),
          ],
        ),
      ),
    );
  }
}
