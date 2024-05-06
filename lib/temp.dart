//   return StreamBuilder(
    //       stream: FirebaseFirestore.instance.collection('Users').snapshots(),
    //       builder: (context, snapshots){
    //         if(snapshots.connectionState == ConnectionState.waiting){
    //           return const Center(
    //             child: CircularProgressIndicator(),
    //           );
    //         } else if(snapshots.hasError){
    //           return Center(
    //             child: Text('${snapshots.error}'),
    //           );
    //         } else{
    //           List<DocumentSnapshot<Object?>> userDocuments = snapshots.data!.docs;
    //           for(int i = 0; i < userDocuments.length; i++){
    //             if(userDocuments[i].id == _user!.uid || userDocuments[i].id == _user!.email!.substring(0, 11)){
    //               userIsRegistered = true;
    //               userIsTeacher = userDocuments[i]['isTeacher'];
    //               if(userIsTeacher){
    //                 teachingCoursesId = userDocuments[i]['teachingCoursesId'].cast<String>();
    //               }else{
    //                 studyingCoursesId = userDocuments[i]['studyingCoursesId'].cast<String>();
    //               }
    //               break;
    //             }
    //           }

    //           if(userIsRegistered){
    //             if(userIsTeacher){
    //               return TeacherHomePage(auth: _auth, user: _user!,);
    //             } else{
    //               // TODO: Remove this later
    //               String entryNumber = _user!.email!.substring(0, 11);
    //               startAdvertising(id: entryNumber);
    //               return StudentHomePage(auth: _auth, user: _user!,);
    //             }
    //           } else{
    //             return RegisterPage(auth: _auth, user: _user!);
    //           }
    //         }
    //       });