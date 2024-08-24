# DAO - Decentralized Autonomous Organzition

## What is taught in this lesson

> 1. We are going to have a contract controlled by a DAO
> 2. Every transaction that the DAO wants to send has to be voted on
> 3. We will use ERC20 tokens for voting(bad model, Please reaserch better models as you get better)

### Creating a token voting DAO using openzeppelin,

- what are the key componenets(token, Governer, TimeLock, etc).
- The lifecycle of a proposal

## What i have learnt

1. What is a DAO: A DAO is a decision-making mechanism facilitated by blockchain technology.
   - Members (maybe any of them?) of a DAO can create proposals and allow all/some members of the DAO to vote on them. Once a proposal is passed, it gets executed.
   - Programmatically, a DAO is a set of smart contracts that make this whole process happen.
   - The key challenge is how to balance efficiency and democracy in the voting process. That why Patrick said that the token voting is bad because it would led to plutocracy.
2. How to design a DAO? Fairness vs Effiency
   1. PoS vs DPoS: Delegating would increase the efficiency of decision-making, but how to prevent the centralization?
   2. Sovereign vs corperate (in vitalik's article "DAOs are not corporations", i believe that sovereign is more decentralized, while the other is more centralized).
   3. convex vs concave
