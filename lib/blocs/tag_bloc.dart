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

class TagUpdated extends TagState {} // To signify a successful update

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

class UpdateTag extends TagEvent {
  final int tagId;
  final String newTitle;

  const UpdateTag(this.tagId, this.newTitle);
}
class GetConnectedTags extends TagEvent {
  final int collectionId;

  const GetConnectedTags(this.collectionId);
}

class AddTagToCollection extends TagEvent {
  final int collectionId;
  final int tagId;

  const AddTagToCollection(this.collectionId, this.tagId);
}


class RemoveTagFromCollection extends TagEvent {
  final int collectionId;
  final int tagId;

  const RemoveTagFromCollection(this.collectionId, this.tagId);
}

// BLoC for Tag Management
class TagBloc extends Bloc<TagEvent, TagState> {
  final TagRepository tagRepository;

  TagBloc(this.tagRepository) : super(TagInitial()) {
    // Load Tags
    on<LoadTags>((event, emit) async {
      emit(TagLoading());
      try {
        // print('bloc');
        final tags = await tagRepository.getTags();
        emit(TagLoaded(tags));
      } catch (e) {
        emit(const TagError('Failed to load tags.'));
      }
    });

    // Create Tag
    on<CreateTag>((event, emit) async {
      emit(TagLoading());
      try {
        await tagRepository.createTag(event.title);
        add(LoadTags()); // Reload tags after creation
      } catch (e) {
        emit(const TagError('Failed to create tag.'));
      }
    });

    // Delete Tag
    on<DeleteTag>((event, emit) async {
      emit(TagLoading());
      try {
        await tagRepository.deleteTag(event.tagId);
        add(LoadTags()); // Reload tags after deletion
      } catch (e) {
        emit(const TagError('Failed to delete tag.'));
      }
    });

    // Update Tag
    on<UpdateTag>((event, emit) async {
      emit(TagLoading());
      try {
        await tagRepository.updateTag(event.tagId, event.newTitle);
        emit(TagUpdated()); // Emit a specific state when a tag is updated
        add(LoadTags()); // Reload tags after update
      } catch (e) {
        emit(const TagError('Failed to update tag.'));
      }
    });

    // Get Connected Tags
    on<GetConnectedTags>((event, emit) async {
      emit(TagLoading());
      try {
        final connectedTags = await tagRepository.getConnectedTags(event.collectionId);
        emit(TagLoaded(connectedTags)); // Assuming you have a TagLoaded state to hold the tags
      } catch (e) {
        emit(const TagError('Failed to retrieve connected tags.'));
      }
    });

    // Add Tag to Collection
    on<AddTagToCollection>((event, emit) async {
      emit(TagLoading());
      try {
        await tagRepository.addTagToCollection(event.collectionId, event.tagId);
        emit(TagUpdated()); // Use the same state to signify success
        add(LoadTags()); // Reload tags after adding to collection
      } catch (e) {
        emit(const TagError('Failed to add tag to collection.'));
      }
    });

    // Remove Tag from Collection
    on<RemoveTagFromCollection>((event, emit) async {
      emit(TagLoading());
      try {
        await tagRepository.removeTagFromCollection(
            event.collectionId, event.tagId);
        emit(TagUpdated()); // Use the same state to signify success
        add(LoadTags()); // Reload tags after removing from collection
      } catch (e) {
        emit(const TagError('Failed to remove tag from collection.'));
      }
    });
  }
}
