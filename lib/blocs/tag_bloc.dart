import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/tag_model.dart';
import '../repositories/tag_repository.dart';


// Define Tag States
abstract class TagState extends Equatable {
  const TagState();

  @override
  List<Object?> get props => [];
}

class TagInitial extends TagState {}
class TagLoading extends TagState {}
class TagLoaded extends TagState {
  final List<Tag> tags;

  const TagLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}
class TagError extends TagState {
  final String message;

  const TagError(this.message);

  @override
  List<Object?> get props => [message];
}

// Define Tag Events
abstract class TagEvent extends Equatable {
  const TagEvent();

  @override
  List<Object?> get props => [];
}

class LoadTags extends TagEvent {}
class CreateTag extends TagEvent {
  final String title;

  const CreateTag(this.title);
}

class DeleteTag extends TagEvent {
  final int tagId;

  const DeleteTag(this.tagId);
}

// BLoC for Tag Management
class TagBloc extends Bloc<TagEvent, TagState> {
  final TagRepository tagRepository;

  TagBloc(this.tagRepository) : super(TagInitial()) {
    on<LoadTags>((event, emit) async {
      emit(TagLoading());
      try {
        final tags = await tagRepository.getTags();
        emit(TagLoaded(tags));
      } catch (e) {
        emit(const TagError('Failed to load tags.'));
      }
    });

    on<CreateTag>((event, emit) async {
      emit(TagLoading());
      try {
        await tagRepository.createTag(event.title);
        add(LoadTags()); // Reload tags after creation
      } catch (e) {
        emit(const TagError('Failed to create tag.'));
      }
    });

    on<DeleteTag>((event, emit) async {
      emit(TagLoading());
      try {
        await tagRepository.deleteTag(event.tagId);
        add(LoadTags()); // Reload tags after deletion
      } catch (e) {
        emit(const TagError('Failed to delete tag.'));
      }
    });
  }
}
