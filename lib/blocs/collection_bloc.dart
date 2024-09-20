import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toby1/blocs/states/collection_state.dart';
import 'package:toby1/models/collection_model.dart';
import 'package:toby1/repositories/collection_repository.dart';



// Define Collection States
abstract class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object?> get props => [];
}

class CollectionInitial extends CollectionState {}

class CollectionLoading extends CollectionState {}

class CollectionLoaded extends CollectionState {
  final List<Collection> collections;

  const CollectionLoaded(this.collections);

  @override
  List<Object?> get props => [collections];
}

class CollectionError extends CollectionState {
  final String message;

  const CollectionError(this.message);

  @override
  List<Object?> get props => [message];
}

// Define Collection Events
abstract class CollectionEvent extends Equatable {
  const CollectionEvent();
  @override
  List<Object?> get props => [];
}

class LoadCollections extends CollectionEvent {}

class CreateCollection extends CollectionEvent {
  final String title;
  final String? description;
  const CreateCollection(this.title, this.description);
}


class CollectionShow extends CollectionEvent {
  final int collectionId;

  const CollectionShow(this.collectionId);

  @override
  List<Object?> get props => [collectionId];
}

// BLoC for Collection Management
class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final CollectionRepository collectionRepository;

  CollectionBloc(this.collectionRepository) : super(CollectionInitial()) {
    on<LoadCollections>((event, emit) async {
      emit(CollectionLoading());
      try {
        final collections = await collectionRepository.getCollections();
        emit(CollectionLoaded(collections));
      } catch (e) {
        // print(e.toString());
        emit(CollectionError('Failed to load collections: ${e.toString()}'));
      }
    });

    on<CollectionShow>((event, emit) async {
      emit(CollectionLoading()); // وضع التطبيق في حالة تحميل البيانات
      try {
        final collection = await collectionRepository.fetchCollection(event.collectionId); // الحصول على البيانات
        emit(SingleCollectionLoaded(  // استخدام الحالة الجديدة
          collection: collection,
          tabs: collection.tabs,  // استخدام التبويبات من النموذج
          tags: collection.tags,  // استخدام العلامات من النموذج
        ));
      } catch (e) {
        emit(CollectionError('Failed to fetch collection: ${e.toString()}'));  // حالة فشل في حالة حدوث خطأ
      }
    });


    on<CreateCollection>((event, emit) async {
      emit(CollectionLoading());
      try {
        await collectionRepository.createCollection(
            event.title, event.description);
        add(LoadCollections()); // Reload collections after creation
      } catch (e) {
        emit(CollectionError('Failed to create collection: ${e.toString()}'));
      }
    });
  }
}
