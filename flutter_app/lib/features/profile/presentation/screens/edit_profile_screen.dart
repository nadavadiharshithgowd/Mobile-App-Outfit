import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/s3_upload_util.dart';
import '../../../../core/widgets/cached_s3_image.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  Uint8List? _avatarBytes;
  Uint8List? _bodyPhotoBytes;
  bool _uploadingAvatar = false;
  bool _uploadingBody = false;
  String? _avatarUploadedUrl;
  String? _bodyUploadedUrl;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _nameController.text = state.user.fullName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _avatarBytes = bytes;
      _uploadingAvatar = true;
    });

    try {
      final uploadUtil = sl<S3UploadUtil>();
      final result = await uploadUtil.uploadFile(
        fileBytes: bytes,
        fileName: picked.name,
        uploadType: 'profile',
      );
      if (mounted) {
        setState(() {
          _uploadingAvatar = false;
          _avatarUploadedUrl = result.s3Key;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo uploaded!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadBodyPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _bodyPhotoBytes = bytes;
      _uploadingBody = true;
    });

    try {
      final uploadUtil = sl<S3UploadUtil>();
      final result = await uploadUtil.uploadFile(
        fileBytes: bytes,
        fileName: picked.name,
        uploadType: 'tryon_person',
      );
      if (mounted) {
        setState(() {
          _uploadingBody = false;
          _bodyUploadedUrl = result.s3Key;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Body photo uploaded!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingBody = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.editProfile),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user =
              state is AuthAuthenticated ? state.user : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar picker
                  GestureDetector(
                    onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.accentSurface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent,
                              width: 3,
                            ),
                          ),
                          child: _uploadingAvatar
                              ? const Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                )
                              : _avatarBytes != null
                                  ? ClipOval(
                                      child: Image.memory(
                                        _avatarBytes!,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      ),
                                    )
                                  : user?.profilePhoto != null
                                      ? ClipOval(
                                          child: CachedS3Image(
                                            imageUrl: user!.profilePhoto,
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 48,
                                          color: AppColors.accent,
                                        ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: AppColors.background,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_avatarUploadedUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: Colors.green.shade600),
                          const SizedBox(width: 4),
                          Text('Photo uploaded',
                              style: AppTextStyles.caption.copyWith(
                                  color: Colors.green.shade600)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email (read-only)
                  TextFormField(
                    initialValue: user?.email ?? '',
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Body photo upload
                  Text(
                    'Full Body Photo (for Try-On)',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload a full-body photo for better try-on results',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 12),

                  // Body photo preview
                  if (_bodyPhotoBytes != null || _uploadingBody) ...[
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _uploadingBody
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                      color: AppColors.accent),
                                  SizedBox(height: 12),
                                  Text('Uploading...',
                                      style: AppTextStyles.caption),
                                ],
                              ),
                            )
                          : Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.memory(
                                  _bodyPhotoBytes!,
                                  fit: BoxFit.cover,
                                ),
                                if (_bodyUploadedUrl != null)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade600,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check,
                                              size: 14,
                                              color: Colors.white),
                                          SizedBox(width: 4),
                                          Text('Uploaded',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  PastelButton(
                    text: _bodyPhotoBytes != null
                        ? 'Change Body Photo'
                        : 'Upload Body Photo',
                    isOutlined: true,
                    icon: Icons.upload_outlined,
                    onPressed:
                        _uploadingBody ? null : _pickAndUploadBodyPhoto,
                  ),
                  const SizedBox(height: 40),

                  // Save button
                  PastelButton(
                    text: AppStrings.save,
                    width: double.infinity,
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<AuthBloc>().add(
                              AuthUpdateProfile(
                                  fullName: _nameController.text.trim()),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated!'),
                          ),
                        );
                        context.pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
