//
//  ViewController.swift
//  PlayingCard
//
//  Created by Ruben on 12/3/17.
//  Copyright © 2017 Ruben. All rights reserved.
//
import UIKit

///
/// Main view controller
///
class ViewController: UIViewController {

    var deck = PlayingCardDeck()
    @IBOutlet var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var cardBehavior = CardBehavior(in: animator)

    override func viewDidLoad() {
        
        var cards: [PlayingCard] = []
        
        // Create pairs of random cards that the user will try to match
        for _ in 1...((cardViews.count+1)/2) {
            if let card = deck.draw() {
                cards += [card, card]
            }
        }
        
        // Setup each cardView
        for cardView in cardViews {
            // Start facing down

            //step 1 cardView.isFaceUp = false
            cardView.isFaceUp = false
            
            // Setup the cardView
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue

            // step 2 Add gesture recognizers
            setupGestureRecognizers(to: cardView)
            
            //add CollisionBehavior
            cardBehavior.addItem(cardView)
        }
    }

    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter {$0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0 ) && $0.alpha == 1}
    }

    private var faceUpCardViewMatch: Bool {
        return faceUpCardViews.count == 2 &&
        faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
        faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }


    //step 2
    private func setupGestureRecognizers(to cardView: PlayingCardView) {
        let tapToFlip = UITapGestureRecognizer(target: self, action: #selector(flipCard(_:)))
        cardView.addGestureRecognizer(tapToFlip)
    }

    var lastChoosenCardView: PlayingCardView?
    @objc private func flipCard(_ recognizer: UITapGestureRecognizer) {

        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
                lastChoosenCardView = chosenCardView
                cardBehavior.removeItem(chosenCardView)
                //rotate the card
                UIView.transition(with: chosenCardView, duration: 0.6 , options: .transitionFlipFromLeft, animations: {
                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                }) { (finished) in
                    let cardsToAnimate = self.faceUpCardViews
                    if self.faceUpCardViewMatch {
                        //transform card
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0, options : [], animations: {
                            self.faceUpCardViews.forEach {
                                $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)

                            }
                        }, completion:  { (position) in
                            //transform card
                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.75  , delay: 0, options: [], animations: {
                                cardsToAnimate.forEach {
                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                    $0.alpha = 0
                                }
                            }, completion:  { (position) in
                                //hidden card
                                cardsToAnimate.forEach {
                                    $0.isHidden = true
                                    $0.alpha = 1
                                    $0.transform = .identity
                                }
                            })
                        })
                    } else if cardsToAnimate.count == 2 {
                        if chosenCardView == self.lastChoosenCardView {
                            cardsToAnimate.forEach { (cardView) in
                                //rotates non-matched cards
                                UIView.transition(with: cardView, duration: 0.6, options: [.transitionFlipFromLeft], animations: {
                                    cardView.isFaceUp = false
                                }, completion: { finished in
                                    self.cardBehavior.addItem(cardView)
                                })
                            }
                        }
                    } else {
                        if !chosenCardView.isFaceUp {
                            self.cardBehavior.addItem(chosenCardView)
                        }
                    }
                }
            }
        default:
            break
        }
    }

}

