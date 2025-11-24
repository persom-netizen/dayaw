class Lesson {
  final int id;
  final String title;
  final String content;
  final String type; // text, multiple_choice, matching, tracing
  final List<String>? options;
  final int? correctAnswerIndex; // For multiple choice questions
  final bool isLocked;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.options,
    this.correctAnswerIndex,
    this.isLocked = false,
  });
}

class Chapter {
  final int id;
  final String title;
  final List<Lesson> lessons;
  final bool isComingSoon;

  Chapter({
    required this.id,
    required this.title,
    required this.lessons,
    this.isComingSoon = false,
  });
}

class SulatinCurriculum {
  static List<Chapter> getAllChapters() {
    return [
      // Kabanata 1 - Introduction to Baybayin (5 lessons)
      Chapter(
        id: 1,
        title: 'Kabanata 1: Panimula sa Baybayin',
        lessons: [
          Lesson(
            id: 1,
            title: 'Ano ang Baybayin?',
            content:
                'Ang Baybayin ay sinaunang sistema ng pagsulat na ginamit ng mga ninuno nating Pilipino bago dumating ang mga Kastila. Ito ay isang alpabetong katinig-patinig (syllabic alphabet) na may 17 pangunahing karakter.\n\nAng salitang "baybayin" ay nagmula sa salitang Tagalog na "baybay" na nangangahulugang "mga dalampasigan" o "pamaglakad sa tabing-dagat", subalit ito rin ay nangangahulugang "pagbaybay" o "ang paraan ng pagsusulat ng mga letra upang makabuo ng salita".',
            type: 'text',
          ),
          Lesson(
            id: 2,
            title: 'Kasaysayan ng Baybayin',
            content:
                'Ang Baybayin ay may mahabang kasaysayan na umaabot pa noong ika-13 siglo. Ito ay bahagi ng mas malaking pamilya ng mga sulat sa Timog-Silangang Asya na nagmula sa Brahmi script ng India.\n\nNang dumating ang mga Kastila noong ika-16 siglo, natagpuan nila na maraming Pilipino ang marunong sumulat gamit ang Baybayin. Ang mga misyonero ay gumamit ng Baybayin upang magturo ng Kristiyanismo hanggang sa unti-unting pinalitan ito ng Latin alphabet.',
            type: 'text',
          ),
          Lesson(
            id: 3,
            title: 'Kahalagahan ng Baybayin',
            content:
                'Ang pag-aaral ng Baybayin ay mahalaga dahil:\n\n1. Ito ay bahagi ng ating kultura at pagkakakilanlan bilang mga Pilipino\n2. Tumutulong ito sa atin na mas maunawaan ang ating kasaysayan\n3. Nagpapakita ito ng kahusayan at katalinuhan ng ating mga ninuno\n4. Nagbibigay ito ng koneksyon sa ating mga ugat at tradisyon\n5. Nag-aalok ito ng alternatibong paraan ng pagpapahayag ng ating wika',
            type: 'text',
          ),
          Lesson(
            id: 4,
            title: 'Saan Ginagamit ang Baybayin Ngayon?',
            content:
                'Sa kasalukuyan, ang Baybayin ay ginagamit sa:\n\n• Sining at Disenyo - sa mga tatuheya, logo, at artwork\n• Edukasyon - sa mga paaralan bilang bahagi ng Filipino subjects\n• Kultura - sa mga pista at pagdiriwang ng kultura\n• Modernong Media - sa mga pelikula, TV shows, at social media\n• Pansariling Gamit - bilang unique na paraan ng pagsulat at pagpapahayag\n\nMaraming mga Pilipino ngayon ang nag-aaral muli ng Baybayin bilang pagpapahalaga sa kanilang kultura.',
            type: 'text',
          ),
          Lesson(
            id: 5,
            title: 'Pagsusulit: Panimula sa Baybayin',
            content: 'Saan nagmula ang salitang "baybayin"?',
            type: 'multiple_choice',
            options: [
              'Sa salitang "baybay" na nangangahulugang tabing-dagat at pagbaybay',
              'Sa pangalan ng isang bayani',
              'Sa isang lugar sa Pilipinas',
              'Wala sa nabanggit',
            ],
            correctAnswerIndex: 0,
          ),
        ],
      ),

      // Kabanata 2 - Basic Characters (3 lessons)
      Chapter(
        id: 2,
        title: 'Kabanata 2: Mga Pangunahing Karakter',
        lessons: [
          Lesson(
            id: 6,
            title: 'Mga Katinig (Consonants)',
            content:
                'Ang Baybayin ay may 14 pangunahing katinig:\n\nB, K, D/R, G, H, L, M, N, NG, P, S, T, W, Y\n\nAng bawat katinig ay may nakadikit na tunog na "A" kapag walang kudlit (tuldok o guhit).\n\nHalimbawa:\n• ᜊ = BA\n• ᜃ = KA\n• ᜇ = DA\n• ᜄ = GA',
            type: 'text',
          ),
          Lesson(
            id: 7,
            title: 'Mga Patinig (Vowels)',
            content:
                'Ang Baybayin ay may 3 independyenteng patinig:\n\n• ᜀ = A\n• ᜁ = I/E\n• ᜂ = O/U\n\nAng mga patinig na ito ay ginagamit sa simula ng salita o kapag nag-iisa.\n\nUpang baguhin ang tunog ng katinig:\n• Kudlit sa itaas (·) = nagbabago ng A sa E/I\n• Kudlit sa ibaba (·) = nagbabago ng A sa O/U\n\nHalimbawa:\n• ᜊ = BA, ᜊᜒ = BI, ᜊᜓ = BO',
            type: 'text',
          ),
          Lesson(
            id: 8,
            title: 'Pagsusulit: Pagtutugma ng mga Karakter',
            content:
                'Itugma ang mga sumusunod na karakter sa kanilang tamang tunog.',
            type: 'matching',
          ),
        ],
      ),

      // Kabanata 3 - Writing Practice (5 lessons, one for each vowel)
      Chapter(
        id: 3,
        title: 'Kabanata 3: Pagsasanay sa Pagsulat',
        lessons: [
          Lesson(
            id: 9,
            title: 'Pagsulat ng Patinig: A',
            content:
                'Sa araling ito, matututunan mo kung paano isulat ang patinig na "A" sa Baybayin.\n\nAng Baybayin para sa A ay: ᜀ\n\nPansinin ang direksiyon ng mga guhit at ang tamang pagkakasunod-sunod ng pagsulat. Magsanay ng pagsulat sa canvas sa ibaba.',
            type: 'tracing',
          ),
          Lesson(
            id: 10,
            title: 'Pagsulat ng Patinig: E',
            content:
                'Sa araling ito, matututunan mo kung paano isulat ang patinig na "E" sa Baybayin.\n\nAng Baybayin para sa E ay: ᜁ\n\nPansinin ang direksiyon ng mga guhit at ang tamang pagkakasunod-sunod ng pagsulat. Magsanay ng pagsulat sa canvas sa ibaba.',
            type: 'tracing',
          ),
          Lesson(
            id: 11,
            title: 'Pagsulat ng Patinig: I',
            content:
                'Sa araling ito, matututunan mo kung paano isulat ang patinig na "I" sa Baybayin.\n\nAng Baybayin para sa I ay: ᜁ\n\nPansinin na ang I at E ay pareho ang karakter sa Baybayin. Magsanay ng pagsulat sa canvas sa ibaba.',
            type: 'tracing',
          ),
          Lesson(
            id: 12,
            title: 'Pagsulat ng Patinig: O',
            content:
                'Sa araling ito, matututunan mo kung paano isulat ang patinig na "O" sa Baybayin.\n\nAng Baybayin para sa O ay: ᜂ\n\nPansinin ang direksiyon ng mga guhit at ang tamang pagkakasunod-sunod ng pagsulat. Magsanay ng pagsulat sa canvas sa ibaba.',
            type: 'tracing',
          ),
          Lesson(
            id: 13,
            title: 'Pagsulat ng Patinig: U',
            content:
                'Sa araling ito, matututunan mo kung paano isulat ang patinig na "U" sa Baybayin.\n\nAng Baybayin para sa U ay: ᜂ\n\nPansinin na ang U at O ay pareho ang karakter sa Baybayin. Magsanay ng pagsulat sa canvas sa ibaba.',
            type: 'tracing',
          ),
        ],
      ),

      // Kabanata 4-10 - Coming Soon
      Chapter(
        id: 4,
        title: 'Kabanata 4: Mga Silaba',
        lessons: [
          Lesson(
            id: 14,
            title: 'Sa susunod na version',
            content: 'Ang araling ito ay hindi pa available.',
            type: 'text',
            isLocked: true,
          ),
        ],
        isComingSoon: true,
      ),
      Chapter(
        id: 5,
        title: 'Kabanata 5: Mga Salitang Pangkaraniwan',
        lessons: [
          Lesson(
            id: 15,
            title: 'Sa susunod na version',
            content: 'Ang araling ito ay hindi pa available.',
            type: 'text',
            isLocked: true,
          ),
        ],
        isComingSoon: true,
      ),
      Chapter(
        id: 6,
        title: 'Kabanata 6: Mga Pangungusap',
        lessons: [
          Lesson(
            id: 16,
            title: 'Sa susunod na version',
            content: 'Ang araling ito ay hindi pa available.',
            type: 'text',
            isLocked: true,
          ),
        ],
        isComingSoon: true,
      ),
      Chapter(
        id: 7,
        title: 'Kabanata 7: Pagbasa ng Baybayin',
        lessons: [
          Lesson(
            id: 17,
            title: 'Sa susunod na version',
            content: 'Ang araling ito ay hindi pa available.',
            type: 'text',
            isLocked: true,
          ),
        ],
        isComingSoon: true,
      ),
      Chapter(
        id: 8,
        title: 'Kabanata 8: Pagsusulat ng Pangalan',
        lessons: [
          Lesson(
            id: 18,
            title: 'Sa susunod na version',
            content: 'Ang araling ito ay hindi pa available.',
            type: 'text',
            isLocked: true,
          ),
        ],
        isComingSoon: true,
      ),
      Chapter(
        id: 9,
        title: 'Kabanata 9: Modernong Baybayin',
        lessons: [
          Lesson(
            id: 19,
            title: 'Sa susunod na version',
            content: 'Ang araling ito ay hindi pa available.',
            type: 'text',
            isLocked: true,
          ),
        ],
        isComingSoon: true,
      ),
      Chapter(
        id: 10,
        title: 'Kabanata 10: Proyekto at Praktis',
        lessons: [
          Lesson(
            id: 20,
            title: 'Sa susunod na version',
            content: 'Ang araling ito ay hindi pa available.',
            type: 'text',
            isLocked: true,
          ),
        ],
        isComingSoon: true,
      ),
    ];
  }
}
