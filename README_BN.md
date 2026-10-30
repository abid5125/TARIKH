# TARIKH — Flutter starter

এটি TARIKH অ্যাপের প্রাথমিক Flutter source scaffold। এতে রয়েছে:
- বাংলা/ইংরেজি ভাষা বাছাইয়ের প্রাথমিক ব্যবস্থা
- Dark/Light theme
- মাদ্রাসা/স্কুল নির্বাচনসহ অফলাইন প্রবেশ স্ক্রিন
- আটটি ইতিহাস বিভাগের হোম স্ক্রিন
- SQLite local database
- লোকাল Admin Panel-এর প্রাথমিক নমুনা

## গুরুত্বপূর্ণ সতর্কতা
1. Admin PIN `2468` কেবল ডেমো। বাস্তব ব্যবহারের আগে শক্তিশালী PIN ও নিরাপদ local authentication যোগ করতে হবে।
2. অফলাইন লগইন প্রতিষ্ঠানের পরিচয় যাচাই করে না; এটি কেবল ব্যবহারকারীর দেওয়া তথ্য নেয়।
3. Admin Panel-এর ডেটা একই ডিভাইসের SQLite-এ থাকে। অন্য ফোনে নিজে থেকে পৌঁছাবে না।
4. ইতিহাসের পূর্ণ, যাচাইকৃত তথ্যভান্ডার এখনো যোগ করা হয়নি। বর্তমান বিভাগ স্ক্রিনগুলো কাঠামো/placeholder।
5. Splash screen-এ অস্থায়ী Flutter gradient ব্যবহার করা হয়েছে। চূড়ান্ত animation ও আলাদা app icon asset পরে সংযুক্ত করতে হবে।

## চালানোর নিয়ম
Flutter SDK-সহ কম্পিউটারে:
```bash
flutter pub get
flutter run
```
APK তৈরির জন্য:
```bash
flutter build apk --release
```

প্রকল্পটি Android Studio / VS Code দিয়ে খুলুন।
