import 'package:catodo/features/data/models/latest-activity-model.dart';
import 'package:catodo/features/data/repositories/focus_session_repository.dart';
import 'package:catodo/features/data/models/focus_session_model.dart';
import 'package:catodo/constants/index.dart';
import 'package:catodo/features/data/repositories/latest_activity_repository.dart';

class FocusFormState {
  final String activity;
  final int duration;
  final DateTime date;
  final List<String> latestActivities;

  const FocusFormState({
    required this.activity,
    required this.duration,
    required this.date,
    required this.latestActivities,
  });

  FocusFormState copyWith({
    String? activity,
    int? duration,
    DateTime? date,
    List<String>? latestActivities,
  }) {
    return FocusFormState(
      activity: activity ?? this.activity,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      latestActivities: latestActivities ?? this.latestActivities,
    );
  }
}

class FormManager {
  static final FormManager _instance = FormManager._internal();
  static FormManager get instance => _instance;

  FocusFormState _state;
  final List<void Function(FocusFormState)> _listeners = [];

  FormManager._internal()
      : _state = FocusFormState(
          activity: '',
          duration: DEFAULT_WORK_TIME,
          date: DateTime.now(),
          latestActivities: [],
        );

  FocusFormState get state => _state;

  Future<List<LatestActivity>> getLatestActivities() async {
    final activities =
        await LatestActivityRepository.instance.getLatestActivities();
    _updateState(_state.copyWith(
        latestActivities: activities.map((e) => e.name).toList()));
    return activities;
  }

  void removeLatestActivity(String activity) async {
    await LatestActivityRepository.instance.removeLatestActivity(activity);
    _updateState(_state.copyWith(
        latestActivities:
            _state.latestActivities.where((e) => e != activity).toList()));
  }

  /// 방금 시작한 활동을 최근 목록에 올린다. 빈 이름은 넣지 않는다.
  void addLatestActivity() {
    if (_state.activity.trim().isEmpty) return;

    if (!_state.latestActivities.contains(_state.activity)) {
      LatestActivityRepository.instance.addLatestActivity(LatestActivity(
        name: _state.activity,
        timestamp: DateTime.now(),
      ));
      _updateState(_state.copyWith(
          latestActivities: [..._state.latestActivities, _state.activity]));
    }
  }

  void addListener(void Function(FocusFormState) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(FocusFormState) listener) {
    _listeners.remove(listener);
  }

  void updateActivity(String activity) {
    _updateState(_state.copyWith(activity: activity));
  }

  void updateDuration(int duration) {
    _updateState(_state.copyWith(duration: duration));
  }

  void _updateState(FocusFormState newState) {
    _state = newState;
    for (var listener in _listeners) {
      listener(_state);
    }
  }


  /// 방금 끝난 집중을 기록에 남기고, 저장된 세션을 돌려준다.
  ///
  /// 저장 시각은 반드시 여기서 새로 찍는다. 예전에는 `_state.date`를 썼는데
  /// 그 값은 매니저가 만들어질 때(= 앱 실행 시점) 한 번 정해져서, 앱을 켜둔 채
  /// 여러 번 집중하면 전부 같은 시각으로 저장됐다. 차트가 세션을 시간대·요일별로
  /// 나눌 때 이 값을 쓰기 때문에 기록 자체가 틀어지는 문제였다.
  Future<FocusSession> save(int focussedTime) async {
    final completedAt = DateTime.now();
    final session = FocusSession(
      activity: _state.activity,
      focusedTime: focussedTime,
      restTime: 0,
      date: completedAt,
    );
    session.id = await FocusSessionRepository.instance.addFocusSession(session);
    _updateState(_state.copyWith(date: completedAt));
    return session;
  }
}
