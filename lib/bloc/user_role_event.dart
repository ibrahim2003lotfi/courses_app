// lib/user_role_bloc/user_role_event.dart
part of 'user_role_bloc.dart';

abstract class UserRoleEvent {
  const UserRoleEvent();
}

class BecomeTeacherEvent extends UserRoleEvent {
  const BecomeTeacherEvent();
}

class ResetRoleEvent extends UserRoleEvent {
  const ResetRoleEvent();
}