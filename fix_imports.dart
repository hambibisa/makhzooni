import 'dart:io';

void main() async {
  final packageName = 'mkhzoni';
    final libDir = Directory('mkhzoni/lib'); // <-- تم تحديد مسار lib الصحيح

      if (!libDir.existsSync()) {
          print('❌ مجلد lib غير موجود في المسار: ${libDir.path}');
              return;
                }

                  int fixedCount = 0;
                    int filesScanned = 0;

                      // استخدام listSync بدلاً من list للتعامل مع المجلدات بشكل صحيح
                        await for (final fileEntity in libDir.list(recursive: true, followLinks: false)) {
                            if (fileEntity is File && fileEntity.path.endsWith('.dart')) {
                                  filesScanned++;
                                        final file = fileEntity;
                                              String content = await file.readAsString();
                                                    String originalContent = content;

                                                          // النمط الأول: يصحح المسارات النسبية الطويلة مثل ../../app/data/models
                                                                final relativePattern = RegExp(r"import '(\.\./)+app/data/models/(.+?\.dart)';");
                                                                      content = content.replaceAllMapped(relativePattern, (match) {
                                                                              final modelFile = match.group(2);
                                                                                      return "import 'package:$packageName/app/data/models/$modelFile';";
                                                                                            });

                                                                                                  // النمط الثاني: يصحح المسارات التي تبدأ بـ app/data/models مباشرة
                                                                                                        final directPattern = RegExp(r"import 'app/data/models/(.+?\.dart)';");
                                                                                                              content = content.replaceAllMapped(directPattern, (match) {
                                                                                                                      final modelFile = match.group(1);
                                                                                                                              return "import 'package:$packageName/app/data/models/$modelFile';";
                                                                                                                                    });
                                                                                                                                          
                                                                                                                                                // النمط الثالث: يصحح المسارات التي تبدأ بـ firebase_options.dart
                                                                                                                                                      final firebasePattern = RegExp(r"import 'firebase_options.dart';");
                                                                                                                                                            content = content.replaceAll(firebasePattern, "import 'package:$packageName/firebase_options.dart';");

                                                                                                                                                                  // النمط الرابع: يصحح المسارات التي تبدأ بـ app/modules
                                                                                                                                                                         final modulesPattern = RegExp(r"import '(\.\./)+app/modules/(.+?\.dart)';");
                                                                                                                                                                                content = content.replaceAllMapped(modulesPattern, (match) {
                                                                                                                                                                                        final screenFile = match.group(2);
                                                                                                                                                                                                return "import 'package:$packageName/app/modules/$screenFile';";
                                                                                                                                                                                                      });


                                                                                                                                                                                                            if (content != originalContent) {
                                                                                                                                                                                                                    await file.writeAsString(content);
                                                                                                                                                                                                                            print('✅ تم تصحيح الاستيراد في: ${file.path}');
                                                                                                                                                                                                                                    fixedCount++;
                                                                                                                                                                                                                                          }
                                                                                                                                                                                                                                              }
                                                                                                                                                                                                                                                }

                                                                                                                                                                                                                                                  print('\n------------------------------------');
                                                                                                                                                                                                                                                    print('🔍 تم فحص $filesScanned ملف.');
                                                                                                                                                                                                                                                      if (fixedCount == 0) {
                                                                                                                                                                                                                                                          print('✨ لم يتم العثور على أي استيرادات تحتاج تصحيح.');
                                                                                                                                                                                                                                                            } else {
                                                                                                                                                                                                                                                                print('🚀 تم تصحيح $fixedCount ملف بنجاح!');
                                                                                                                                                                                                                                                                  }
                                                                                                                                                                                                                                                                    print('------------------------------------');
                                                                                                                                                                                                                                                                    }
                                                                                                                                                                                                                                                                    