import 'package:flutter_bloc/flutter_bloc.dart';
import 'prescription_event.dart';
import 'prescription_state.dart';
import '../repositories/prescription_repository.dart';
import '../repositories/auth_repository.dart';
import '../models/opd.dart';

class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final PrescriptionRepository prescriptionRepository;
  final AuthRepository authRepository;

  PrescriptionBloc({
    required this.prescriptionRepository,
    required this.authRepository,
  }) : super(PrescriptionInitial()) {
    on<PrescriptionLoadOpdList>(_onLoadOpdList);
    on<PrescriptionLoadDetails>(_onLoadDetails);
    on<PrescriptionReset>(_onReset);
  }

  Future<void> _onLoadOpdList(
    PrescriptionLoadOpdList event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(PrescriptionOpdListLoading());

    try {
      final user = await authRepository.getSavedUser();

      if (user == null || user.isTokenExpired) {
        emit(
          const PrescriptionError(
            'Authentication required. Please login again.',
          ),
        );
        return;
      }

      print('📋 Loading OPDs for booklet: ${event.bookletNo}');
      final opds = await prescriptionRepository.getOpdsByBooklet(
        user.token,
        event.bookletNo,
      );

      emit(PrescriptionOpdListLoaded(opds));
    } catch (e) {
      print('❌ Error loading   list: $e');
      emit(PrescriptionError('Failed to load appointments: $e'));
    }
  }

  Future<void> _onLoadDetails(
    PrescriptionLoadDetails event,
    Emitter<PrescriptionState> emit,
  ) async {
    // Preserve the OPD list while loading prescription details
    List<Opd> currentOpds = [];
    if (state is PrescriptionOpdListLoaded) {
      currentOpds = (state as PrescriptionOpdListLoaded).opds;
    } else if (state is PrescriptionDetailsLoaded) {
      currentOpds = (state as PrescriptionDetailsLoaded).opds;
    } else if (state is PrescriptionDetailsLoading) {
      currentOpds = (state as PrescriptionDetailsLoading).opds;
    }

    emit(PrescriptionDetailsLoading(currentOpds));

    try {
      final user = await authRepository.getSavedUser();

      if (user == null || user.isTokenExpired) {
        // Restore the OPD list instead of showing auth error
        if (currentOpds.isNotEmpty) {
          emit(PrescriptionOpdListLoaded(currentOpds));
        } else {
          emit(
            const PrescriptionError(
              'Authentication required. Please login again.',
            ),
          );
        }
        return;
      }

      print('💊 Loading prescriptions for OPD ID: ${event.opdId}');
      final prescriptions = await prescriptionRepository
          .getPrescriptionsByOpdId(user.token, event.opdId);

      print('💊 [BLOC] Loaded ${prescriptions.length} prescriptions');
      print('💊 [BLOC] Emitting PrescriptionDetailsLoaded state');

      emit(PrescriptionDetailsLoaded(currentOpds, prescriptions));
    } catch (e) {
      print('❌ Error loading prescription details: $e');
      print('💊 [BLOC] Restoring OPD list state (${currentOpds.length} OPDs)');
      // Restore the OPD list instead of going to error state
      // This allows the user to go back and see the list
      if (currentOpds.isNotEmpty) {
        emit(PrescriptionOpdListLoaded(currentOpds));
      } else {
        emit(PrescriptionError('Failed to load prescription details: $e'));
      }
    }
  }

  Future<void> _onReset(
    PrescriptionReset event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(PrescriptionInitial());
  }
}
