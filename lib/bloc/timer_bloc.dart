import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timer/bloc/timer_event.dart';
import 'package:timer/bloc/timer_state.dart';

import '../ticker.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final int _duration = 60;
  final Ticker _ticker;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  // TODO: implement initialState
  TimerState get initialState => Ready(_duration);

  @override
  Stream<TimerState> mapEventToState(TimerEvent event) async* {
    if (event is Start) {
      yield* _mapStartToState(event);
    } else if(event is Pause){
      yield* _mapPauseToState(event);
    } else if(event is Resume) {
      yield* _mapResumeToState(event);
    } else if(event is Reset){
      yield* _mapResetToState(event);
    } else if(event is Tick){
      yield* _mapTickToState(event);
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Stream<TimerState> _mapStartToState(Start start) async* {
    yield Running(start.duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .ticker(ticks: start.duration)
        .listen((duration) => add(Tick(duration: duration)));
  }

  Stream<TimerState> _mapPauseToState(Pause pause) async* {

    if(state is Running){
      _tickerSubscription?.pause();
      yield Paused(state.duration);
    }

  }

  Stream<TimerState> _mapResumeToState(Resume resume) async*{

    if(state is Paused){
      _tickerSubscription?.resume();
      yield Running(state.duration);
    }

  }


  Stream<TimerState> _mapResetToState(Reset reset) async*{

    _tickerSubscription?.cancel();
    yield Ready(_duration);

  }

  Stream<TimerState> _mapTickToState(Tick tick) async*{

    yield tick.duration > 0 ? Running(tick.duration) : Finished();

  }
}
