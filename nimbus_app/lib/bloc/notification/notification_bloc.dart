import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dto/notification_dto.dart';
import '../../services/notification_service.dart';

/// NotificationBloc — in-app notification list and read state.
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsLoadRequested extends NotificationEvent {
  const NotificationsLoadRequested();
}

class NotificationMarkRead extends NotificationEvent {
  final String notificationId;

  const NotificationMarkRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationState {}

class NotificationsLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<Notification> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationsFailure extends NotificationState {
  final String message;

  const NotificationsFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService _notificationService;

  NotificationBloc({required NotificationService notificationService})
      : _notificationService = notificationService,
        super(NotificationsInitial()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationMarkRead>(_onMarkRead);
  }

  Future<void> _onLoad(
    NotificationsLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationsLoading());
    try {
      final notifications = await _notificationService.getNotifications();
      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount:
            notifications.where((n) => n.read != true).length,
      ));
    } catch (e) {
      emit(NotificationsFailure(e.toString()));
    }
  }

  Future<void> _onMarkRead(
    NotificationMarkRead event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded) return;
    try {
      await _notificationService.markRead(event.notificationId);
      final updated = current.notifications
          .map((n) =>
              n.id == event.notificationId ? _withRead(n) : n)
          .toList();
      emit(NotificationsLoaded(
        notifications: updated,
        unreadCount: updated.where((n) => n.read != true).length,
      ));
    } catch (_) {
      // Read-state is best-effort; keep the list as-is on failure.
    }
  }

  Notification _withRead(Notification n) {
    return Notification(
      id: n.id,
      userId: n.userId,
      title: n.title,
      body: n.body,
      type: n.type,
      referenceId: n.referenceId,
      read: true,
      createdAt: n.createdAt,
    );
  }
}
