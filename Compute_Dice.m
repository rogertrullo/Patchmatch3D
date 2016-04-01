function Dice= Compute_Dice(labelA,labelB)

intersection=and(labelA,labelB);
eltsA=sum(labelA(:));
eltsB=sum(labelB(:));
eltsint=sum(intersection(:));
Dice=2*eltsint/(eltsA+eltsB);


end