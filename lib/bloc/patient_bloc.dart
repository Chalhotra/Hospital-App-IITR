import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';
import '../repositories/patient_repository.dart';
import 'patient_event.dart';
import 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository patientRepository;
  final AuthRepository authRepository;

  PatientBloc({required this.patientRepository, required this.authRepository})
    : super(PatientInitial()) {
    on<PatientLoadRequested>(_onPatientLoadRequested);
    on<PatientBookletChanged>(_onPatientBookletChanged);
  }

  Future<void> _onPatientLoadRequested(
    PatientLoadRequested event,
    Emitter<PatientState> emit,
  ) async {
    print('🔍 [PATIENT BLOC] Loading patient info...');
    emit(PatientLoading());

    try {
      // First, try to load from cache
      final cachedBooklets = await authRepository.getSavedPatientInfo();
      final cachedActiveBookletNo = await authRepository.getActiveBookletNo();

      if (cachedBooklets != null && cachedBooklets.isNotEmpty) {
        print(
          '✅ [PATIENT BLOC] Loaded ${cachedBooklets.length} booklet(s) from cache',
        );

        // Find active booklet or default to first
        final activeBooklet = cachedActiveBookletNo != null
            ? cachedBooklets.firstWhere(
                (b) => b.bookletNo == cachedActiveBookletNo,
                orElse: () => cachedBooklets[0],
              )
            : cachedBooklets[0];

        print('✅ [PATIENT BLOC] Active booklet: ${activeBooklet.bookletNo}');
        emit(
          PatientLoaded(booklets: cachedBooklets, activeBooklet: activeBooklet),
        );
        return;
      }

      // If no cache, fetch from API
      print('🔍 [PATIENT BLOC] No cache found, fetching from API...');
      final booklets = await patientRepository.getPatientInfo(event.token);

      if (booklets.isEmpty) {
        print('⚠️ [PATIENT BLOC] No booklets found');
        emit(const PatientError('No booklets found'));
        return;
      }

      // Save to cache
      await authRepository.savePatientInfo(booklets, booklets[0].bookletNo);

      // Set the first booklet as active by default
      print('✅ [PATIENT BLOC] Loaded ${booklets.length} booklet(s)');
      print('✅ [PATIENT BLOC] Active booklet: ${booklets[0].bookletNo}');

      emit(PatientLoaded(booklets: booklets, activeBooklet: booklets[0]));
    } catch (e) {
      print('❌ [PATIENT BLOC] Error loading patient info: $e');
      emit(PatientError(e.toString()));
    }
  }

  Future<void> _onPatientBookletChanged(
    PatientBookletChanged event,
    Emitter<PatientState> emit,
  ) async {
    print('🔄 [PATIENT BLOC] Changing active booklet to: ${event.bookletNo}');

    if (state is PatientLoaded) {
      final currentState = state as PatientLoaded;

      // Find the booklet with the matching bookletNo
      final newActiveBooklet = currentState.booklets.firstWhere(
        (booklet) => booklet.bookletNo == event.bookletNo,
        orElse: () => currentState.activeBooklet,
      );

      // Save active booklet to cache
      await authRepository.updateActiveBooklet(event.bookletNo);

      print(
        '✅ [PATIENT BLOC] Active booklet changed to: ${newActiveBooklet.fullName}',
      );

      emit(currentState.copyWith(activeBooklet: newActiveBooklet));
    }
  }
}
