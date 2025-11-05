import 'package:equatable/equatable.dart';

abstract class PrescriptionEvent extends Equatable {
  const PrescriptionEvent();

  @override
  List<Object> get props => [];
}

class PrescriptionLoadOpdList extends PrescriptionEvent {
  final String bookletNo;

  const PrescriptionLoadOpdList(this.bookletNo);

  @override
  List<Object> get props => [bookletNo];
}

class PrescriptionLoadDetails extends PrescriptionEvent {
  final int opdId;

  const PrescriptionLoadDetails(this.opdId);

  @override
  List<Object> get props => [opdId];
}

class PrescriptionReset extends PrescriptionEvent {
  const PrescriptionReset();
}
