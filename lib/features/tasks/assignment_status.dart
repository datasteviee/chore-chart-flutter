import '../../widgets/design_system/assignment_card.dart';

AssignmentCardVariant assignmentVariantForRow({
  required String status,
  required DateTime dueDate,
  required DateTime today,
}) {
  switch (status) {
    case 'done':
      return AssignmentCardVariant.done;
    case 'skipped':
      return AssignmentCardVariant.skipped;
    case 'overdue':
      return AssignmentCardVariant.overdue;
    case 'pending':
      final d = DateTime(dueDate.year, dueDate.month, dueDate.day);
      final t = DateTime(today.year, today.month, today.day);
      if (d.isBefore(t)) return AssignmentCardVariant.overdue;
      return AssignmentCardVariant.pending;
    default:
      return AssignmentCardVariant.pending;
  }
}
