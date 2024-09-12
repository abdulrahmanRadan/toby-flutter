
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toby1/models/tab_model.dart';
import 'package:toby1/repositories/tab_repository.dart';



// Define Tab States
abstract class TabState extends Equatable {
  const TabState();

  @override
  List<Object?> get props => [];
}

class TabInitial extends TabState {}
class TabLoading extends TabState {}
class TabLoaded extends TabState {
  final List<AppTab> tabs;

  const TabLoaded(this.tabs);

  @override
  List<Object?> get props => [tabs];
}
class TabError extends TabState {
  final String message;

  const TabError(this.message);

  @override
  List<Object?> get props => [message];
}

// Define Tab Events
abstract class TabEvent extends Equatable {
  const TabEvent();

  @override
  List<Object?> get props => [];
}

class LoadTabs extends TabEvent {
  final int collectionId;

  const LoadTabs(this.collectionId);
}

class CreateTab extends TabEvent {
  final String title;
  final String url;
  final int collectionId;

  const CreateTab(this.title, this.url, this.collectionId);
}

class DeleteTab extends TabEvent {
  final int tabId;

  const DeleteTab(this.tabId);
}

// BLoC for Tab Management
class TabBloc extends Bloc<TabEvent, TabState> {
  final TabRepository tabRepository;

  TabBloc(this.tabRepository) : super(TabInitial()) {
    on<LoadTabs>((event, emit) async {
      emit(TabLoading());
      try {
        final tabs = await tabRepository.getTabs(event.collectionId);
        emit(TabLoaded(tabs));
      } catch (e) {
        emit(const TabError('Failed to load tabs.'));
      }
    });

    on<CreateTab>((event, emit) async {
      emit(TabLoading());
      try {
        await tabRepository.createTab(event.title, event.url, event.collectionId);
        add(LoadTabs(event.collectionId)); // Reload tabs after creation
      } catch (e) {
        emit(const TabError('Failed to create tab.'));
      }
    });

    on<DeleteTab>((event, emit) async {
      emit(TabLoading());
      try {
        await tabRepository.deleteTab(event.tabId);
        emit(TabInitial());
      } catch (e) {
        emit(const TabError('Failed to delete tab.'));
      }
    });
  }
}
