// lib/user_role_bloc/user_role_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_role_event.dart';
part 'user_role_state.dart';

class UserRoleBloc extends Bloc<UserRoleEvent, UserRoleState> {
  UserRoleBloc() : super(const UserRoleState(isTeacher: false)) {
    on<BecomeTeacherEvent>(_onBecomeTeacher);
    on<ResetRoleEvent>(_onResetRole);
  }

  void _onBecomeTeacher(BecomeTeacherEvent event, Emitter<UserRoleState> emit) {
    emit(state.copyWith(isTeacher: true));
  }

  void _onResetRole(ResetRoleEvent event, Emitter<UserRoleState> emit) {
    emit(state.copyWith(isTeacher: false));
  }

  // Helper method to check if user is teacher
  bool get isTeacher => state.isTeacher;
}