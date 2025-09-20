import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gate_pass_project/screens/view_job_details/job_details_model.dart';

part 'job_details_event.dart';
part 'job_details_state.dart';
part 'job_details_bloc.freezed.dart';

class JobDetailsBloc extends Bloc<JobDetailsEvent, JobDetailsState> {
  JobDetailsBloc() : super(_Initial()) {
    on<JobDetailsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
