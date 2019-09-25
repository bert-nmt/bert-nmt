### BLEU scores of IWSLT translation tasks  
<table id="iwslt translation bleus" class="display" style="width:100%">
<thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">En&rarr;De</th>
      <th scope="col">De&rarr;En</th>
      <th scope="col">En&rarr;Es</th>
      <th scope="col">En&rarr;Zh</th>
      <th scope="col">En&rarr;Fr</th>
    </tr>
</thead>
<tbody>
    <tr>
      <td>Standard Transformer</td>
      <td>28.57</td>
      <td>34.64</td>
      <td>39.0</td>
      <td>26.3</td>
      <td>35.9</td>
    </tr> 
    <tr>
      <td>Our BERT-fused NMT</td>
      <td>30.45</td>
      <td>36.11</td>
        <td>41.4</td>
      <td>28.2</td>
      <td>38.7</td>
    </tr> 
  </tbody>
</table>


### BLEU scores of WMT’14 translation 
<table id="wmt translation bleus" class="display" style="width:100%">
<thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">En&rarr;De</th>
      <th scope="col">En&rarr;Fr</th>
    </tr>
</thead>
<tbody>
    <tr>
      <td>DynamicConv</td>
      <td>29.7</td>
       <td>43.2</td>
    </tr> 
    <tr>
      <td>Evolved Transformer</td>
      <td>29.8</td>
      <td>41.3</td>
    </tr> 
    <tr>
      <td>Transformer + large batch </td>
      <td>29.3</td>
       <td>43.0</td>
    </tr> 
    <tr>
      <td>Our reprorduced Transformer</td>
      <td>29.12</td>
      <td>42.96</td>
    </tr> 
     <tr>
      <td>Our BERT-fused NMT</td>
      <td>30.75</td>
      <td>43.78</td>
    </tr> 
 </tbody>
</table>

### Comparisons on inference time (seconds)
<table id="inference time" class="display" style="width:100%">
<thead>
    <tr>
      <th scope="col">Dataset</th>
      <th scope="col">Transformer</th>
      <th scope="col">Ours</th>
      <th scope="col">(+)</th>
    </tr>
</thead>
<tbody>
    <tr>
      <td>IWSLT14 En&rarr;De</td>
      <td>70</td>
      <td>97</td>
      <td>38.6%</td>
    </tr> 
    <tr>
      <td>IWSLT14 De&rarr;en</td>
      <td>69</td>
      <td>103</td>
      <td>49.3%</td>
    </tr> 
    <tr>
      <td>WMT14 En&rarr;De</td>
      <td>67</td>
      <td>99</td>
      <td>47.8%</td>
    </tr> 
    <tr>
      <td>WMT14 En&rarr;Fr</td>
      <td>89</td>
      <td>128</td>
      <td>43.8%</td>
    </tr> 
 </tbody>   
</table>



### BLEU scores of IWSLT document-level translation 
<table id="wmt translation bleus" class="display" style="width:100%">
<thead>
    <tr>
      <th scope="col"></th>
      <th scope="col">En&rarr;De</th>
      <th scope="col">De&rarr;En</th>
    </tr>
</thead>
<tbody>
    <tr>
      <td>Sentence-level Transformer baseline</td>
      <td>28.57</td>
      <td>34.64</td>
    </tr> 
    <tr>
      <td>Our simple document-level baseline</td>
      <td>28.90</td>
      <td>34.95</td>
    </tr> 
    <tr>
      <td> </td>
      <td>27.94</td>
      <td>33.97</td>
    </tr> 
    <tr>
      <td>Sentence-level + BERT</td>
      <td>30.45</td>
      <td>36.11</td>
    </tr> 
     <tr>
      <td>Document-level + BERT</td>
      <td>31.02</td>
      <td>36.69</td>
    </tr> 
 </tbody>
</table>

### Ablation study on IWSLT’14 En&rarr;De
<table id="wmt translation bleus" class="display" style="width:100%">
<tbody>
    <tr>
      <td>Standard Transformer</td>
      <td>28.57</td>
    </tr> 
    <tr>
      <td>BERT-fused NMT</td>
      <td>30.45</td>
    </tr> 
    <tr>
      <td>Training NMT module from scratch</td>
      <td>27.03</td>
    </tr> 
    <tr>
      <td>Jointly tune BERT and NMT</td>
      <td>28.87</td>
    </tr> 
    <tr>
      <td>Use BERT to initialize the encoder of NMT</td>
      <td>27.14</td>
    </tr> 
    <tr>
      <td>Use XLM to initialize the encoder of NMT</td>
      <td>28.22</td>
    </tr> 
    <tr>
      <td>Use XLM to initialize the decoder of NMT</td>
      <td>26.13</td>
    </tr> 
    <tr>
      <td>Use XLM to initialize both the encoder and decoder of NMT</td>
      <td>28.99</td>
    </tr>
<tr>
      <td>ELMO</td>
      <td>29.67</td>
    </tr> 
    <tr>
      <td>Remove BERT-encoder attention</td>
      <td>29.87</td>
    </tr> 
    <tr>
      <td>Remove BERT-decoder attention</td>
      <td>29.90</td>
    </tr> 
    <tr>
      <td>Stack attention</td>
      <td>29.35</td>
    </tr> 
    <tr>
      <td>12-layer encoder</td>
      <td>29.27</td>
    </tr> 
    <tr>
      <td>18-layer encoder</td>
      <td>28.92</td>
    </tr> 
 </tbody>
</table>


### BLEU scores of WMT’16 Ro&rarr;En translation
<table id="wmt translation bleus" class="display" style="width:100%">
    <thead>
    <tr>
      <th scope="col">Methods </th>
      <th scope="col">BLEU</th>
    </tr>
</thead>
<tbody>
    <tr>
      <td>Sennrich</td>
      <td>33.9</td>
    </tr> 
    <tr>
      <td>XLM</td>
      <td>38.5</td>
    </tr> 
    <tr>
      <td>Standard Transformer</td>
      <td>33.12</td>
    </tr> 
    <tr>
      <td>+ back translation</td>
      <td>37.73</td>
    </tr> 
    <tr>
      <td>+ BERT-fused NMT</td>
      <td>39.10</td>
    </tr> 
 </tbody>
</table>


### BLEU scores of unsupervised NMT
<table id="wmt translation bleus" class="display" style="width:100%">
    <thead>
    <tr>
      <th scope="col"> </th>
      <th scope="col">En&rarr;Fr</th>
        <th scope="col">Fr&rarr;En</th>
        <th scope="col">En&rarr;Ro</th>
        <th scope="col">Ro&rarr;En</th>
    </tr>
</thead>
<tbody>
    <tr>
      <td>Lample</td>
      <td>27.6</td>
        <td>27.7</td>
        <td>25.1</td>
        <td>23.9</td>
    </tr> 
  <tr>
      <td>XLM</td>
      <td>33.4</td>
        <td>33.3</td>
        <td>33.3</td>
        <td>31.8</td>
    </tr>
    <tr>
      <td>MASS</td>
      <td>37.50</td>
        <td>34.90</td>
        <td>35.20</td>
        <td>33.10</td>
    </tr>
    <tr>
      <td>XLM (Our reproduced)</td>
      <td>37.57</td>
        <td>34.64</td>
        <td>35.33</td>
        <td>32.85</td>
    </tr>
    <tr>
      <td>+ BERT-fused NMT</td>
      <td>38.27</td>
        <td>35.62</td>
        <td>36.02</td>
        <td>33.20</td>
    </tr>
 </tbody>
</table>
