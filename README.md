A latex template for Sogang University thesis
=============================================
서강대학교 논문 템플릿
======================

## 0.Preliminary
=======================
1. Tex Live 2013~(Supports KoTeX), or any other TeX distribution with KoTeX installed.
2. A text editor. (VSCode is recommended)


## 1.Usage
=======================
```bash
├── Makefile
├── README.md
├── make.bat
├── clean.bat
├── covers
│   ├── approval.doc : 논문인준서 워드 파일, 수정하여 approval.pdf로 저장한 후 사용
│   ├── approval.pdf
│   ├── abstract.tex
│   ├── acknowledgement.tex
│   └── krabstract.tex
├── figures : 챕터별로 들어가는 그림들
│   ├── figure_chap_1
│   ├── figure_chap_2
│   ├── figure_chap_3
│   ├── figure_chap_4
│   ├── figure_chap_5
│   ├── figure_chap_6
│   └── figure_orig
├── tables : 표 목록
│   ├── realaudio.tex
│   └── userstudy.tex
├── library.bib : 참고문헌 목록
├── setup : 설정 파일
│   ├── preamble.tex
│   └── SGUThesis.cls : 양식 파일
├── text : 챕터별 내용 텍스트
│   ├── appendix.tex
│   ├── chapter1.tex
│   ├── chapter2.tex
│   ├── chapter3.tex
│   ├── chapter4.tex
│   ├── chapter5.tex
│   ├── conclusion.tex
│   └── introduction.tex
└── thesis.tex : 컴파일 해야 하는 메인 파일
```
* 초록: abstract.tex
* 감사의 글: acknowledgement.tex

위 두 개의 파일은 내용만 수정하면 됩니다.

 * 논문 템플릿: SGUThesis.cls
KUThesis.cls(고려대학교 논문 양식) 을 기반으로, 서강대학교 양식에 맞추어 수정했습니다. 
2024년 02월 졸업자 기준으로 겉표지, 속표지 등의 양식에 이슈가 없었습니다.
다만, 논문 인준서 관련 양식은 수정이 필요합니다. 추후 업데이트 예정입니다.

* 논문 메인 파일 : thesis.tex
* 참고문헌 목록 : library.bib


참고문헌 목록은 학술지 페이지의 BibTeX 형식으로 제공되는 데이타를 사용하면 됩니다.
예를들어 http://rmp.aps.org/abstract/RMP/v30/i2/p257_1 페이지에 들어가 보면 중간에 Export 라고 돼 있는 부분 오른쪽에 BibTeX 이라고 돼 있는 버튼을 눌러 다운받을 수 있게 돼 있는데, 그 정보들을 채워넣으면 됩니다. 논문 본문에서는 해당 파일의 첫번째 인자를 사용하면 됩니다. 제시한 예제에서는 첫 번째 인자가 RevModPhys.30.257 이므로, \cite{RevModPhys.30.257}와 같이 사용하면 됩니다.

컴파일 방법
===========

유닉스 환경에서는 `make`, 윈도우에서는 `make.bat`을 실행시키면 자동으로 컴파일이 되어 `thesis.pdf`파일이 생성됩니다. 중간에 뭔가 꼬여 처음부터 컴파일을 해야 할 일이 있다면, 유닉스 환경에서는 `make clean`, 윈도에어서는 `clean.bat`을 이용해서 초기화 할 수 있습니다. 이 때 사용자가 작성한 파일들은 날아가지 않으나 항상 조심하는게 좋으니 **백업을 강력하게 권장합니다.**

주의
====

이 템플릿 파일을 사용해서 발생하는 모든 문제에 대해서 템플릿 작성자들은 어떠한 책임도 지지 않습니다.
논문 인준서의 경우, 양식을 Tex으로 쓸 수가 없어서 워드 파일을 첨부했습니다. 수정 후, pdf 변환하여 사용하면 됩니다.
(Tex에서 원문자 인 기호를 지원하지 않기 때문입니다.)

참고 자료
=========
https://gradsch.sogang.ac.kr/gradsch/file/학위논문작성지침.pdf
http://library.korea.ac.kr/link/html/useThesesGuide03
