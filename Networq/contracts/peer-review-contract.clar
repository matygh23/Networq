;; Professional Network Smart Contract - Stage 1
;; Basic decentralized professional networking with user profiles

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))

;; Data Variables
(define-data-var next-profile-id uint u1)

;; Data Maps
(define-map profiles
  { user: principal }
  {
    name: (string-ascii 50),
    title: (string-ascii 100),
    bio: (string-ascii 500),
    created-at: uint
  }
)

(define-map connections
  { user-a: principal, user-b: principal }
  { connected: bool, timestamp: uint }
)

;; Public Functions

;; Create a professional profile
(define-public (create-profile (name (string-ascii 50)) (title (string-ascii 100)) (bio (string-ascii 500)))
  (let ((user tx-sender))
    (asserts! (is-none (map-get? profiles { user: user })) err-already-exists)
    (map-set profiles
      { user: user }
      {
        name: name,
        title: title,
        bio: bio,
        created-at: block-height
      }
    )
    (var-set next-profile-id (+ (var-get next-profile-id) u1))
    (ok true)
  )
)

;; Update profile information
(define-public (update-profile (name (string-ascii 50)) (title (string-ascii 100)) (bio (string-ascii 500)))
  (let ((user tx-sender))
    (asserts! (is-some (map-get? profiles { user: user })) err-not-found)
    (map-set profiles
      { user: user }
      {
        name: name,
        title: title,
        bio: bio,
        created-at: block-height
      }
    )
    (ok true)
  )
)

;; Connect with another user
(define-public (connect-user (other-user principal))
  (let ((user tx-sender))
    (asserts! (is-some (map-get? profiles { user: user })) err-not-found)
    (asserts! (is-some (map-get? profiles { user: other-user })) err-not-found)
    (asserts! (not (is-eq user other-user)) err-unauthorized)
    (map-set connections
      { user-a: user, user-b: other-user }
      { connected: true, timestamp: block-height }
    )
    (map-set connections
      { user-a: other-user, user-b: user }
      { connected: true, timestamp: block-height }
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get user profile
(define-read-only (get-profile (user principal))
  (map-get? profiles { user: user })
)

;; Check if users are connected
(define-read-only (are-connected (user-a principal) (user-b principal))
  (default-to false (get connected (map-get? connections { user-a: user-a, user-b: user-b })))
)

;; Get total number of profiles created
(define-read-only (get-profile-count)
  (- (var-get next-profile-id) u1)
)