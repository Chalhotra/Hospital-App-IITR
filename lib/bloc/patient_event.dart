import 'package:equatable/equatable.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class PatientLoadRequested extends PatientEvent {
  final String token;

  const PatientLoadRequested(this.token);

  @override
  List<Object?> get props => [token];
}

class PatientBookletChanged extends PatientEvent {
  final String bookletNo;

  const PatientBookletChanged(this.bookletNo);

  @override
  List<Object?> get props => [bookletNo];
}
