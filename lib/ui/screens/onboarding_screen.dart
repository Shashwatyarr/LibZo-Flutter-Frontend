import 'package:bookproject/ui/widgets/app_background.dart';
import 'package:bookproject/utils/fonts.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int _index = 0;

  final List<Map<String, String>> data = [
    {
      "title": "Unlock Infinite Stories",
      "subtitle":
          "Find books shared by people around you.Explore categories and trending collections.",
      "image": "",
    },
    {
      "title": "Find Readers Near You",
      "subtitle":
          "Share your books with others and borrow easily.Save money while exploring more.",
      "image": "",
    },
    {
      "title": "Build You Digital Library",
      "subtitle":
          "Track borrowed and shared books.Build your personal digital library.",
      "image": "",
    },
  ];

  void nextPage() {
    if (_index < 2) {
      pageController.nextPage(
        duration: Duration(microseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, "/login"),
                    child: Text('Skip',style: AppTextStyles.subtitle(color: Colors.grey.shade700),),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: data.length,
                  onPageChanged: (i) => setState(() {
                    _index = i;
                  }),
                  itemBuilder: (_, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Expanded(child: Container(
                            margin: EdgeInsets.all(40),
                            decoration: BoxDecoration(image: DecorationImage(image:  NetworkImage(data[i]["image"]!),fit: BoxFit.cover),borderRadius: BorderRadius.circular(20)),
                          )
                          ),
                          SizedBox(height: 20),
                          Text(
                            data[i]["title"]!,
                            style: AppTextStyles.title(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12),
                          Text(
                            data[i]["subtitle"]!,
                            style: AppTextStyles.subtitle(
                              fontSize: 20,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return AnimatedContainer(
                    duration: Duration(microseconds: 300),
                    margin: EdgeInsets.all(4),
                    width: _index == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _index == i ? Color(0xFF00CC96) : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00CC96).withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: GestureDetector(
                  onTap: nextPage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Gradient Glow Behind Button
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF0262FF).withOpacity(0.5),
                              Color(0xFF0077FF).withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF0262FF).withOpacity(0.3),
                              blurRadius: 25,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),

                      // Actual Button
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF0262FF),
                              Color(0xFF0077FF),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _index == 2 ? "Get Started" : "Next",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_right_alt_rounded,
                              color: Colors.white,
                              size: 22,
                              shadows: [
                                Shadow(
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Already have an account?',style: AppTextStyles.subtitle(
                    color: Colors.grey.shade300,
                    fontSize: 13
                  ),),
                    GestureDetector(
                      onTap: ()=>Navigator.pushReplacementNamed(context,"/login"),
                      child: Text(' Login',style:TextStyle(color: Color(0xFF00CC96),fontSize: 14,fontWeight: FontWeight.bold
                      ,
                        shadows: [
                          Shadow(
                            blurRadius: 8,            // soft shadow
                            color: Color(0xFF00CC96).withOpacity(0.5),    // shadow color
                          ),
                        ],),)
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
