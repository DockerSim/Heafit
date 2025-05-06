import 'package:flutter/material.dart';
import 'package:heafit/constants/theme.dart';
import 'package:heafit/widgets/section_title.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // 선택된 메인 카테고리 인덱스
  int _selectedCategoryIndex = 0;

  // 메인 카테고리 목록
  final List<Map<String, dynamic>> _mainCategories = [
    {'name': '전체', 'icon': Icons.apps},
    {'name': '카페', 'icon': Icons.coffee},
    {'name': '음식점', 'icon': Icons.restaurant},
    {'name': '쇼핑', 'icon': Icons.shopping_bag},
    {'name': '영화', 'icon': Icons.movie},
    {'name': '뷰티', 'icon': Icons.face},
    {'name': '여행', 'icon': Icons.flight},
  ];

  // 서브 카테고리 (브랜드/체인점) 목록 - 카페 카테고리 예시
  final List<Map<String, dynamic>> _cafeSubCategories = [
    {'name': '스타벅스', 'imageUrl': 'assets/images/starbucks.jpg'},
    {'name': '투썸플레이스', 'imageUrl': 'assets/images/twosome.jpg'},
    {'name': '이디야', 'imageUrl': 'assets/images/ediya.jpg'},
    {'name': '커피빈', 'imageUrl': 'assets/images/coffeebean.jpg'},
    {'name': '할리스', 'imageUrl': 'assets/images/hollys.jpg'},
    {'name': '폴바셋', 'imageUrl': 'assets/images/paulbassett.jpg'},
  ];

  // 혜택 목록 - 스타벅스 예시
  final List<Map<String, dynamic>> _benefits = [
    {
      'title': '스타벅스 50% 할인',
      'description': '신한카드로 결제 시 최대 5,000원 할인',
      'period': '2023-05-01 ~ 2023-06-30',
      'tags': ['신한카드', '50%', '할인'],
    },
    {
      'title': '스타벅스 1+1',
      'description': '아메리카노 주문 시 케이크 1개 무료',
      'period': '2023-05-15 ~ 2023-05-31',
      'tags': ['1+1', '아메리카노', '케이크'],
    },
    {
      'title': '스타벅스 사이렌 오더 추가 할인',
      'description': '사이렌 오더로 주문 시 10% 추가 할인',
      'period': '2023-05-10 ~ 2023-06-10',
      'tags': ['사이렌 오더', '10%', '추가 할인'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카테고리'), elevation: 0),
      body: Column(
        children: [
          // 메인 카테고리 목록
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mainCategories.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _mainCategories[index]['icon'],
                          color:
                              isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _mainCategories[index]['name'],
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 서브 카테고리와 혜택 목록
          Expanded(
            child:
                _selectedCategoryIndex == 0
                    ? _buildAllCategories()
                    : _buildCategoryDetail(),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCategories() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _mainCategories.length - 1, // '전체' 제외
      itemBuilder: (context, index) {
        final category = _mainCategories[index + 1]; // '전체' 제외
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategoryIndex = index + 1;
            });
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      category['icon'],
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryDetail() {
    // 선택된 카테고리에 따라 다른 서브 카테고리 표시
    // 여기서는 예시로 카페 카테고리만 구현
    return Column(
      children: [
        // 서브 카테고리 (브랜드/체인점) 섹션
        const SectionTitle(title: '브랜드'),
        SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _cafeSubCategories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // 브랜드 선택 시 해당 브랜드의 혜택 표시
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _cafeSubCategories[index]['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _cafeSubCategories[index]['name'],
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 혜택 목록 섹션
        const SectionTitle(title: '혜택'),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _benefits.length,
            itemBuilder: (context, index) {
              final benefit = _benefits[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        benefit['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            benefit['period'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            (benefit['tags'] as List<String>).map((tag) {
                              return Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: AppTheme.primaryColor
                                    .withOpacity(0.1),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
