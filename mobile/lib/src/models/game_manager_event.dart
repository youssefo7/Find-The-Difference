enum GameManagerEvent {
  message,
  createChat,
  deleteChat,
  joinChat,
  leaveChat,
  chatCreated,
  chatDeleted,
  chatJoined,
  chatLeft,
  serverMessage,
  chatNotFound,
  cannotJoinGameChat,
  cannotLeaveGameChat,
  alreadyInChat,
  notInChat,
  notChatCreator,
  cannotJoinGeneralChat,
  cannotLeaveGeneralChat,
  cannotDeleteGeneralChat,

  requestOrAcceptFriend,
  refuseOrRemoveFriend,
  notifyNewFriendRequest,
  notifyNewFriend,
  notifyFriendRemoved,
  notifyFriendRequestRefused,
  notifyNewUser,

  cheatModeEvent,
  identifyDifference,
  leaveGame,
  sendHint,
  joinGameObserver,
  playerLeave,
  startGame,
  endGame,
  differenceFound,
  differenceNotFound,
  showError,
  removePixels,
  timeEvent,
  changeTemplate,
  onInstanceDeletion,
  receiveHint,
  observerJoinedEvent,
  observerLeavedEvent,
  observerStateSync,

  buyGame,
  hint,
  getGamesToSell,
  gamesToSell,
  updateBalance,

  instantiateGame,
  joinGame,
  approvePlayer,
  rejectPlayer,
  changeTeam,
  endSelection,
  joinRequests,
  waitingRefusal,
  assignGameMaster,
  invalidStartingState,
  getWaitingGames,
  waitingGames,
}
