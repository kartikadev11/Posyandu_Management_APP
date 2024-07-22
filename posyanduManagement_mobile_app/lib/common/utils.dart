import 'package:posyandumanagement_mobile_app/data/models/schedule.dart';
import 'package:intl/intl.dart';

String dateByStatus(Schedule schedule) {
  switch (schedule.status) {
    case 'Queue':
      return _formatDateTime1(schedule.createdAt!);
    case 'Review':
      return _formatDateTime1(schedule.submitDate!);
    case 'Approved':
      return _formatDateTime1(schedule.approvedDate!);
    case 'Rejected':
      return _formatDateTime1(schedule.rejectedDate!);
    default:
      return "-";
  }
}

String _formatDateTime1(DateTime dateTime) {
  return DateFormat('d MMM yyyy, HH:mm').format(dateTime);
}

String iconByStatus(Schedule schedule) {
  switch (schedule.status) {
    case 'Review':
      return "assets/review_icon.png";
    case 'Approved':
      return "assets/ceklis.png";
    case 'Rejected':
      return "assets/silang.png";
    default:
      return "assets/queue.png";
  }
}
