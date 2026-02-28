import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'di/injection_container.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/wardrobe/presentation/bloc/wardrobe_bloc.dart';
import 'features/wardrobe/presentation/bloc/upload_bloc.dart';
import 'features/outfit/presentation/bloc/outfit_bloc.dart';
import 'features/tryon/presentation/bloc/tryon_bloc.dart';
import 'router/app_router.dart';

class OutfitStylistApp extends StatelessWidget {
  const OutfitStylistApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = sl<AuthBloc>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => authBloc),
        BlocProvider<WardrobeBloc>(create: (_) => sl<WardrobeBloc>()),
        BlocProvider<UploadBloc>(create: (_) => sl<UploadBloc>()),
        BlocProvider<OutfitBloc>(create: (_) => sl<OutfitBloc>()),
        BlocProvider<TryOnBloc>(create: (_) => sl<TryOnBloc>()),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: createRouter(authBloc),
      ),
    );
  }
}
