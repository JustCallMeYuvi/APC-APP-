abstract class ComplaintResidentEvent {}

class FetchComplaints extends ComplaintResidentEvent {
  final String empNo;
  FetchComplaints(this.empNo);
}