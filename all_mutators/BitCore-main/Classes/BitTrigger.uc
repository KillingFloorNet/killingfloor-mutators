/**
 * Author:      Marco
 * Home repo:   https://github.com/InsultingPros/BitCore
 */
class BitTrigger extends UseTrigger;

var transient float MessageTimer;
var BitTripArcade Arcade;

function UsedBy(Pawn User) {
    if (User.IsHumanControlled()) {
        Arcade.StartGame(PlayerController(User.Controller));
    }
}

function Touch(Actor Other) {
    if (MessageTimer < Level.TimeSeconds && Pawn(Other) != none && Pawn(Other).IsHumanControlled()) {
        // Send a string message to the toucher.
        Pawn(Other).ClientMessage(Message);
        MessageTimer = Level.TimeSeconds + 0.5f;
    }
}

defaultproperties {
    Message="Press [Use] to play some BIT.TRIP Core"
    bMovable=false
    CollisionRadius=120
}