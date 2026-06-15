# Abstract and Introduction Korean Translation

Source files:
- `covers/abstract.tex`
- `text/chapter1.tex`

## Abstract 한글 해석

본 논문은 직접적인 full-band 처리를 위한 time-frequency 음성 향상 구조인 TF-Rehancer를 제안한다. 제안 모델은 48 kHz 음성의 고주파 성분을 대역 제한 입력으로부터 생성해야 하는 결손 정보가 아니라, 입력에 이미 존재하지만 잡음에 의해 훼손된 spectral evidence로 다룬다. TF-Rehancer는 sampling-frequency-independent STFT 분석, power-law compressed complex spectral conditioning, 저대역 encoder가 안내하는 고대역 token update와 이후의 full-band decoder modeling, 그리고 원 noisy STFT 위에서 수행되는 local complex time-frequency filtering을 사용한다.

본 논문은 TF-Rehancer를 세 가지 관점에서 평가한다. 첫째, 16 kHz VoiceBank+DEMAND benchmark에서 low-computation TF-Rehancer configuration은 0.47M parameters와 1.89G model-side MACs로 PESQ 3.33, DNSMOS SIG 3.41, DNSMOS BAK 4.04, DNSMOS OVL 3.13을 달성한다. Paper-reported FastEnhancer-M reference와 비교했을 때, 이 모델은 더 적은 model-side MACs로 PESQ, SI-SDR, DNSMOS P.835에서 더 높은 수치를 보고하지만, FastEnhancer-M은 SCOREQ와 ESTOI에서 약간 더 강하다. 이 비교는 same-evaluator ranking이 아니라 benchmark context로 해석한다.

둘째, 48 kHz reference positioning table은 VoiceBank+DEMAND 48 kHz test set에서 TF-Rehancer를 published DeepFilterNet2 reference와 비교한다. TF-Rehancer는 경쟁력 있는 full-reference score를 보이지만, DeepFilterNet2 row는 locally re-evaluated baseline이 아니라 paper-reported reference로 남아 있다. 셋째, controlled 48 kHz ablation은 complex TF filtering을 direct spectrum mapping으로 대체하면 full-reference, spectral, non-intrusive metric이 저하됨을 보인다. 또한 decoder cross-attention은 perceptual score와 spectral fidelity 사이의 trade-off를 바꾸며, 5 kHz low-band cutoff는 controlled ablation setting에서 균형적인 operating point를 제공한다.

## Chapter 1. Introduction 한글 해석

기존의 많은 speech enhancement benchmark와 baseline은 전통적인 16 kHz wideband setting을 중심으로 구성되어 있다. 이 설정에서는 48 kHz full-band speech에 포함된 upper-band spectral component가 모델 입력 바깥에 놓인다. 따라서 직접적인 48 kHz full-band speech enhancement는 다른 동작 조건을 갖는다. 모델은 noisy full-band signal을 입력으로 받고, upper-band spectrum은 향상해야 할 noisy evidence로 이미 주어진다. 기존 연구에서도 full-band enhancement가 다루어졌지만, 직접적인 48 kHz full-band SE에 대한 same-protocol reference는 전통적인 wideband evaluation에 비해 아직 충분히 정립되어 있지 않다.

Speech bandwidth extension과 speech super-resolution은 서로 다른 정보 조건을 목표로 한다. 이들 task는 band-limited input으로부터 사라지거나 훼손된 high-frequency content를 복원하는 것을 목표로 한다. 반면 48 kHz full-band SE는 noisy full-band observation에서 출발한다. 따라서 핵심 문제는 wideband enhancement 이후 upper band를 합성하는 것이 아니라, 관측된 full spectrum 전체에서 noise를 억제하면서 유용한 spectral evidence를 보존하는 것이다. 이러한 차이는 high-frequency region을 나중에 생성할 missing component가 아니라 noisy observation의 일부로 다루는 direct full-band enhancement 접근을 동기화한다.

PercepNet과 DeepFilterNet2 같은 practical full-band system은 엄격한 computational constraint 아래에서도 full-band enhancement가 가능하다는 것을 보여주었다. PercepNet은 perceptually motivated critical-band feature와 comb filtering을 사용하고, DeepFilterNet2는 ERB-domain enhancement와 deep filtering을 결합한다. 이러한 perceptual-band frontend는 효율성을 위해 bin-level spectral resolution을 희생한다. 이는 learned frequency representation을 사용하면서도 원 noisy STFT 위의 complex filtering을 통해 enhanced spectrum을 추정하는 보완적인 TF-domain design을 동기화한다.

모든 full-band frequency token에 heavy TF modeling을 직접 적용하는 것은 계산 비용이 클 수 있다. 특히 sampling rate가 증가하면 STFT bin 수가 함께 증가하므로 비용 문제가 더 커진다. Harmonic 및 formant와 관련된 speech-structure evidence는 주로 lower frequency에 집중되어 있고, upper-frequency bin은 noisy input 안에 이미 관측되어 있다. 따라서 더 무거운 encoding은 low-band structure에 집중하고, high band는 decoder-side observed-query evidence로 전달하는 설계가 자연스럽다.

본 논문은 full-band speech enhancement를 위한 refinement-oriented time-frequency architecture인 TF-Rehancer를 제안한다. 핵심 아이디어는 low-band encoder-guided high-band token update 이후 full-band decoder modeling을 수행하는 것이다. TF-Rehancer는 low-band speech-structure evidence를 encode하고, 관측된 upper-band information을 decoder path에 유지하며, low-band context를 사용해 observed high-band decoder token을 update한 뒤, 그 결과로 만들어진 full embedded sequence를 modeling한다. Enhanced spectrum은 latent representation으로부터 clean spectrum을 직접 생성하는 방식이 아니라, 원 noisy STFT 위에서 complex filtering을 수행하여 추정한다. 이 설계는 모델이 cross-band speech structure를 활용하면서도 최종 추정이 관측된 noisy signal에 묶여 있도록 한다.

Attention 관점에서 보면, decoder representation은 먼저 low-band encoder output과 observed high-band query를 concatenate한 뒤 decoder width로 projection하여 만들어진다. Cross-attention stage에서는 high-band decoder token만 query로 동작하고, low-band encoder output은 key-value context를 제공한다. Update된 high-band token은 low-band decoder token과 다시 결합되며, 이후 frequency self-attention과 temporal module이 full embedded sequence를 modeling한다. 따라서 TF-Rehancer는 low-band information만으로 high-band speech를 생성하지 않는다. 대신 low-band context를 사용해 관측된 high-band feature의 update를 condition한다.

Figure 1.1은 TF-Rehancer의 conceptual overview를 보여준다. Low-band encoder output은 observed high-band decoder token을 update하기 위한 key-value context를 제공한다. 그 결과로 만들어진 full embedded sequence는 이후 modeling되고, 원 noisy STFT 위에서 local complex filter를 추정하는 데 사용된다.

본 논문은 TF-Rehancer를 16 kHz VoiceBank+DEMAND comparison과 48 kHz controlled full-band ablation으로 평가한다. 16 kHz experiment는 lightweight speech enhancement reference와의 quality-efficiency trade-off를 살펴본다. 48 kHz experiment는 해당 setting을 cross-system full-band ranking으로 취급하지 않고, full-band processing 아래에서 TF-Rehancer의 architectural component를 분석한다.

본 논문의 기여는 다음과 같다.

1. 본 논문은 48 kHz full-band SE를 observation-preserving refinement 문제로 정식화한다. 여기서 upper-band component는 wideband processing 이후 생성해야 할 missing content가 아니라 noisy spectral evidence로 다룬다.

2. 본 논문은 observed high-band decoder token을 low-band encoder context로 update한 뒤, 그 결과로 만들어진 full embedded sequence를 modeling하고 noisy STFT 위의 complex filtering으로 enhanced spectrum을 추정하는 TF-domain architecture인 TF-Rehancer를 제안한다.

3. 본 논문은 16 kHz quality-efficiency comparison과 controlled 48 kHz ablation을 제공한다. 이를 통해 complex filtering, decoder cross-attention, low-band cutoff를 분석하되, 48 kHz setting을 cross-system full-band ranking으로 해석하지 않는다.

본 논문의 나머지 구성은 다음과 같다. Chapter 2는 wideband enhancement, bandwidth extension, practical full-band enhancement와 관련된 선행 연구를 검토한다. Chapter 3은 TF-Rehancer architecture와 training objective를 설명한다. Chapter 4는 experimental setup, benchmark result, ablation analysis를 제시한다. Chapter 5는 논문을 요약하고 limitation과 future work를 논의한다.
