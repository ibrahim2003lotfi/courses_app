// lib/user_role_bloc/user_role_state.dart
part of 'user_role_bloc.dart';

class UserRoleState {
  final bool isTeacher;

  const UserRoleState({
    required this.isTeacher,
  });

  UserRoleState copyWith({
    bool? isTeacher,
  }) {
    return UserRoleState(
      isTeacher: isTeacher ?? this.isTeacher,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserRoleState &&
      other.isTeacher == isTeacher;
  }

  @override
  int get hashCode => isTeacher.hashCode;
}