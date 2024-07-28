---
layout: page
title: Plausible Reasoning and Spatial-Statistical Theory
permalink: /spatial-stats-theory/
---

<p style="color:Gray">C. Donegan (2024). Plausible Reasoning and Spatial-Statistical Theory: A Critique of Recent Writings on 'Spatial Confounding'. <em>Geographical Analysis</em>. DOI:<a href="https://doi.org/10.1111/gean.12408">10.1111/gean.12408</a> (open access)</p>

<p style="color:Gray">
<b> Abstract </b> <br/>
Statistical research on correlation with spatial data dates at least to Student's (W. S. Gosset's) 1914 paper on “the elimination of spurious correlation due to position in time and space.” Since 1968, much of this work has been organized around the concept of spatial autocorrelation (SA). A growing statistical literature is now organized around the concept of “spatial confounding” (SC) but is estranged from, and often at odds with, the SA literature and its history. The SC literature is producing new, sometimes flawed, statistical techniques such as Restricted Spatial Regression (RSR). This article brings the SC literature into conversation with the SA literature and provides a theoretically grounded review of the history of research on correlation with spatial data, explaining some of its implications for the the SC literature. The article builds upon principles of plausible inference to synthesize a guiding theoretical thread that runs throughout the SA literature. This leads to a concise theoretical critique of RSR and a clarification of the logic behind standard spatial-statistical models.
</p>

This paper stems partly from an interest in the historical development of spatial-statistical theory. What kinds of theoretical concepts have researchers used to justify and understand their use of various techniques for the analysis of spatial data? This topic has beco), and to argue that the principles can clarify the logic me particularly important recently since established methods in spatial statistics have been challenged and questioned by a number of influential statisticians. Hodges and Reich (2010), for one, argue that using standard methods from spatial statistics 'can mess up' estimates of correlation because the adjustments they make are haphazard. This has given rise to a new literature organized around a concept of 'spatial confounding'.

What is perhaps most interesting about the writings on 'spatial confounding' is that its proponents question some very basic concepts that are often used to understand what we are doing when we do spatial statistics. This raises a methodological challenge because contemporary statistical research very often takes theory for granted in order to focus on mathematical and computational developments. What is at issue, so it seems to me, is the *logical validity* of the adjustments that are being made by spatial statistical methods. The crux of the issue is that some researchers are not accepting the results of spatial-statistical models because they find the adjustments these methods make to be *counter-intuitive* and weakly justified by proponents. 

Previous generations of statistical researchers (including geographers) clearly did not share that intuition and, moreover, they put forth a variety of ideas that have been neglected by recent writings on spatial confounding. The objectives of this paper are to put the recent criticisms of standard spatial methods into conversation with the long history of research on correlation with spatial data and to articulate an intuitive logical basis for such methods by connecting them to some basic principles of spatial reasoning. 

### Statistical methods as science?

Liker all disciplines, statistics has its own internal culture that shapes how research is undertaken and reported. In a provocative and insightful paper, Hodges (2019) writes the following:

> We argue that...our discipline has little understanding of how contemporary models and methods map data to inferential summaries; that we lack such understanding, even for models as simple as this [regression with varying intercepts and slopes], because of a near-exclusive reliance on mathematics as a means of understanding; and that math alone is no longer sufficient. (Abstract)

Hodges argues that research in statistical methods would benefit form treating its subject matter like biological researchers treat their subject matter. His proposal is for statistical methods researchers to make more extensive and deliberate use of simulation studies; specifically, he shows how one can employ simulation studies iteratively to examine the properties of a system and to test hypotheses about how that system (mal-) functions.

This kind of work requires explicit attention be given to hypothesis generation:

> hypothesis generation is one of the central creative activities of scientific work and a key difference between competent and brilliant scientists is that the latter pose more fruitful and penetrating hypotheses. (11)

Yet:

> The mathematical approach to studying statistical methods does include hypotheses; they are called unproven conjectures and rarely see the light of day unless they are proven, while disproofs of scientific hypotheses are routinely published. (11)

Hodges presents a compelling and important argument in favor of approaching statistical research differently. Notably, the interdisciplinary literature on spatial autocorrelation (SA) has long used simulation studies in a way that is similar to what Hodges is proposing. We might add that another shortcoming of the 'pure mathematics' approach is that it can lead to a neglect of the history and substantive development of ideas within one's own field of study. 

Treating statistical methods research as a science opens up a set of derivative questions that are germane to philosophy of science. For instance, if statistical researchers are going to focus more on hypothesis generation, how are they supposed to do that? Is it an inexplicable phenomenon that is outside the scope of logic and method, as Popper argues? Or is hypothesis generation and creative theorization a skill that one can practice by employing principles of probable inference and abstraction, as Po&#769;lya argues?

Another important question pertains to the object of study: what exactly are statistical researchers studying? Are statistical methods concerned with long-run frequencies, the properties of mathematical equations, or as Jeffreys and Jaynes argue, is probability theory a branch of logic? The nature of one's work and the kinds of new ideas one is inclined to entertain hangs on the answer to this question.

### Plausible reasoning

I borrow the term 'plausible reasoning' (PR) from George Po&#769;lya's work on probability theory. Po&#769;lya was interested in qualitative patterns of reasoning and problem solving and their role in science and mathematics. He set out "to study induction inductively" by examining how great mathematicians and scientists, like Euler and Galileo, worked through difficult problems. James Franklin (2001) has described this area of probability theory as "ordinary language reasoning about probabilities," as distinct from the domain of statistics and quantitative reasoning about probabilities. The study of uncertain inference involves basic questions such as

> [H]ow to decide the strength with which evidence supports a conclusion, how to combine pieces of evidence that support each other, and what to do when pieces of evidence conflict,

topics that have appeared in writing for (at least) the past two thousands years, with notable interest among scholars of law (Franklin 2001, xi). 

Po&#769;lya introduces another component of probable inference that does not appear in Franklin's description: creativity. How do we generate new ways of looking at things? How do we come to elaborate new theories? *Analogy* is 'the fuel and fire of thinking', at least according to Hofstadter and Sander (2013). Analogy is how one transfers conceptual structures from one domain to another (seemingly unrelated one), transforming them along the way.  Bohm and Peat write similarly of the importance of 'creative perception in the form of a metaphor'. Po&#769;lya's contribution was to treat analogy as part of non-demonstrative logic, to elaborate its own structure, and to integrate it into his broader logic of probable inference.

If one is to treat statistical research like a science, Po&#769;lya's writings on method are a natural place to start.

### PR and spatial reasoning

The *Geographical Analysis* article cited above is based on a dissertation chapter which served as a case study in plausible reasoning. The idea was to allow Po&#769;lya's theories of analogy and evidence to guide the chapter's study of spatial-statistical theory. The study also borrows some qualitative or heuristic principles from Po&#769;lya's inductive logic and extends them (by analogy) to the domain of spatial reasoning. 

In the new literature on 'spatial confounding', it has been asserted that the problem of estimating correlations with spatial data is a fairly new one. There is, however, a long history of statistical research on correlation with spatial data which dates back at least to the early twentieth century. Although the idea of removing (spatial) confounders is an important one in this history, the problem of SA has been understood using a variety of closely interrelated concepts including degrees of freedom, information redundancy, effective sample size, variance inflation, clustering, and inflation/deflation factors. Confounding appears as just one facet of a many-sided problem. The *GA* paper draws from this history of ideas, from Po&#769;lya's heuristics, and a Monte Carlo study to synthesize some intuitive principles that seem to be present throughout this body of work.

Although the paper may not convince critics of conventional spatial statistics, the paper aims to push the debate forward by situating spatial methods within a longer and richer intellectual history than some have recognized and by articulating an intuitive basis to the logic behind them.


<p style="color:Gray">
<b> References </b> <br/>
</p>

<p style="color:Gray">
D. Bohm & F. D. Peat (1987). <i>Science, Order, and Creativity</i>. Bantam Books. </p>

<p style="color:Gray">
J. Franklin (2001) <i>The Science of Conjecture: Evidence and Probability Before Pascal</i>. The Johns Hopkins University Press. </p>

<p style="color:Gray; text-indent:20px">
 - (2013) "Non-deductive logic in mathematics: the probability of conjectures," in A. Aberdein and I. Dove, eds, <i>The Argument of Mathematics</i> (Springer, 2013), 11-29. <a href="https://web.maths.unsw.edu.au/~jim/argumentnonded.pdf">PDF</a>
</p>

<p style="color:Gray">
J.S. Hodges & B.J. Reich (2010) Adding Spatially-Correlated Errors Can Mess up the Fixed Effects you Love. <i>The American Statistician</i>, 64(4), 325–334. <a href="https://doi.org/10.1198/tast.2010.10052">https://doi.org/10.1198/tast.2010.10052</a>.
</p>

<p style="color:Gray">
J.S. Hodges (2019) Statistical methods research done as science rather than mathematics. arXiv. <a href="https://doi.org/10.48550/arXiv.1905.08381">https://doi.org/10.48550/arXiv.1905.08381</a>.
</p>

<p style="color:Gray">
D. Hofstadter & E. Sander (2013) <i>Surfaces and Essences: Analogy as the Fuel and Fire of Thinking</i>. Basic Books.
</p>

<p style="color:Gray">
G. Polya (1954) <i>Mathematics and Plausible Reasoning</i> (2 vols). Princeton University Press.
</p>

<p style="color:Gray">
E. T. Jaynes (2003) <i>Probability Theory: The Logic of Science</i>. Cambridge University Press.
</p>


