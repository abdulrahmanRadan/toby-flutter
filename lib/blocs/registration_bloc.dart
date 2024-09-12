import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toby1/repositories/api_service.dart';

// Define Registration States
abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object> get props => [];
}

class RegistrationInitial extends RegistrationState {}
class RegistrationLoading extends RegistrationState {}
class RegistrationSuccess extends RegistrationState {}
class RegistrationError extends RegistrationState {
  final String message;
  const RegistrationError(this.message);

  @override
  List<Object> get props => [message];
}

// Define Registration Events
abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object> get props => [];
}

class RegisterRequested extends RegistrationEvent {
  final String name;
  final String email;
  final String password;

  const RegisterRequested(this.name, this.email, this.password);
}

// BLoC for Registration
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final ApiService apiService;

  RegistrationBloc(this.apiService) : super(RegistrationInitial()) {
    on<RegisterRequested>((event, emit) async {
      emit(RegistrationLoading());
      try {
        final response = await apiService.register(event.name, event.email, event.password);
        if (response['success']) {
          emit(RegistrationSuccess());
        } else {
          emit(RegistrationError('Registration sddsfsdf failed'));
        }
      } catch (e) {
        emit(RegistrationError(e.toString()));
      }
    });
  }
}
