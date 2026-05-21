import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../user_role.dart';

const String teacherRegisterCode = 'KAREKOD2026';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final teacherCodeController = TextEditingController();
  final phoneController = TextEditingController();

  UserRole selectedRole = UserRole.parent;
  bool isPasswordVisible = false;
  bool isLoading = false;
  bool isLoadingChildren = true;

  List<Map<String, dynamic>> children = [];
  String? selectedChildId;

  @override
  void initState() {
    super.initState();
    fetchChildrenForParentRegister();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    teacherCodeController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> fetchChildrenForParentRegister() async {
    try {
      final response = await supabase
          .from('children')
          .select('id, full_name, classroom')
          .order('full_name', ascending: true);

      final loadedChildren = List<Map<String, dynamic>>.from(response);

      setState(() {
        children = loadedChildren;
        selectedChildId =
            loadedChildren.isNotEmpty ? loadedChildren.first['id'] : null;
        isLoadingChildren = false;
      });
    } catch (error) {
      setState(() {
        isLoadingChildren = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çocuk listesi alınırken hata oluştu: $error'),
        ),
      );
    }
  }

  Future<void> registerUser() async {
    final fullName = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final teacherCode = teacherCodeController.text.trim();
    final phone = phoneController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad soyad, e-posta ve şifre boş bırakılamaz.'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifre en az 6 karakter olmalıdır.'),
        ),
      );
      return;
    }

    if (selectedRole == UserRole.parent && phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veli telefon numarası boş bırakılamaz.'),
        ),
      );
      return;
    }

    if (selectedRole == UserRole.parent && selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veli hesabı için çocuk seçimi zorunludur.'),
        ),
      );
      return;
    }

    if (selectedRole == UserRole.teacher &&
        teacherCode != teacherRegisterCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Öğretmen kayıt kodu hatalı.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': selectedRole.name,
        },
      );

      final user = authResponse.user;

      if (user == null) {
        throw 'Kullanıcı oluşturulamadı.';
      }

      await supabase.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'email': email,
        'role': selectedRole.name,
        'phone': selectedRole == UserRole.parent ? phone : null,
      });

      if (selectedRole == UserRole.parent) {
        await supabase.from('child_parents').insert({
          'child_id': selectedChildId,
          'parent_id': user.id,
        });
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarılı. Şimdi giriş yapabilirsin.'),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kayıt olurken hata oluştu: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleName = selectedRole == UserRole.teacher ? 'Öğretmen' : 'Veli';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Ad Soyad',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'E-posta',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: passwordController,
            obscureText: !isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Şifre',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              suffixIcon: IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Kullanıcı Rolü',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          SegmentedButton<UserRole>(
            segments: const [
              ButtonSegment(
                value: UserRole.parent,
                label: Text('Veli'),
                icon: Icon(Icons.family_restroom),
              ),
              ButtonSegment(
                value: UserRole.teacher,
                label: Text('Öğretmen'),
                icon: Icon(Icons.school),
              ),
            ],
            selected: {selectedRole},
            onSelectionChanged: (value) {
              setState(() {
                selectedRole = value.first;

                if (selectedRole == UserRole.parent) {
                  teacherCodeController.clear();
                } else {
                  phoneController.clear();
                  selectedChildId = null;
                }
              });
            },
          ),

          if (selectedRole == UserRole.parent) ...[
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Veli Telefon Numarası',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedChildId,
              decoration: const InputDecoration(
                labelText: 'Çocuğunuzu Seçin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.child_care),
              ),
              items: children.map((child) {
                final childName = child['full_name'] ?? 'İsimsiz Öğrenci';
                final classroom = child['classroom'] ?? 'Sınıf bilgisi yok';

                return DropdownMenuItem<String>(
                  value: child['id'],
                  child: Text('$childName - $classroom'),
                );
              }).toList(),
              onChanged: isLoadingChildren
                  ? null
                  : (value) {
                      setState(() {
                        selectedChildId = value;
                      });
                    },
            ),
          ],

          if (selectedRole == UserRole.teacher) ...[
            const SizedBox(height: 12),
            TextField(
              controller: teacherCodeController,
              decoration: const InputDecoration(
                labelText: 'Öğretmen Kayıt Kodu',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.verified_user),
                helperText: 'Öğretmen hesabı açmak için kurum kodu gereklidir.',
              ),
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isLoading ? null : registerUser,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add),
              label: Text(
                isLoading ? 'Kaydediliyor...' : '$roleName olarak kayıt ol',
              ),
            ),
          ),
        ],
      ),
    );
  }
}