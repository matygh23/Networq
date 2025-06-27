;; Professional Network Smart Contract - Stage 2
;; Advanced decentralized professional networking with credentials and endorsements

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))

;; Data Variables
(define-data-var next-profile-id uint u1)
(define-data-var next-credential-id uint u1)

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

(define-map credentials
  { credential-id: uint }
  {
    owner: principal,
    title: (string-ascii 100),
    issuer: (string-ascii 100),
    description: (string-ascii 300),
    verified: bool,
    verifier: (optional principal),
    issued-at: uint
  }
)

(define-map endorsements
  { endorser: principal, endorsed: principal, skill: (string-ascii 50) }
  {
    comment: (string-ascii 200),
    timestamp: uint
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

;; Add a credential
(define-public (add-credential (title (string-ascii 100)) (issuer (string-ascii 100)) (description (string-ascii 300)))
  (let 
    (
      (credential-id (var-get next-credential-id))
      (user tx-sender)
    )
    (asserts! (is-some (map-get? profiles { user: user })) err-not-found)
    (map-set credentials
      { credential-id: credential-id }
      {
        owner: user,
        title: title,
        issuer: issuer,
        description: description,
        verified: false,
        verifier: none,
        issued-at: block-height
      }
    )
    (var-set next-credential-id (+ credential-id u1))
    (ok credential-id)
  )
)

;; Verify a credential (only by designated verifier)
(define-public (verify-credential (credential-id uint) (user principal))
  (let 
    (
      (credential (unwrap! (map-get? credentials { credential-id: credential-id }) err-not-found))
      (verifier tx-sender)
    )
    (asserts! (is-eq (get owner credential) user) err-unauthorized)
    (map-set credentials
      { credential-id: credential-id }
      (merge credential { 
        verified: true, 
        verifier: (some verifier) 
      })
    )
    (ok true)
  )
)

;; Give an endorsement
(define-public (endorse-skill (endorsed principal) (skill (string-ascii 50)) (comment (string-ascii 200)))
  (let ((endorser tx-sender))
    (asserts! (is-some (map-get? profiles { user: endorser })) err-not-found)
    (asserts! (is-some (map-get? profiles { user: endorsed })) err-not-found)
    (asserts! (not (is-eq endorser endorsed)) err-unauthorized)
    (map-set endorsements
      { endorser: endorser, endorsed: endorsed, skill: skill }
      {
        comment: comment,
        timestamp: block-height
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

;; Get credential by ID
(define-read-only (get-credential (credential-id uint))
  (map-get? credentials { credential-id: credential-id })
)

;; Check if users are connected
(define-read-only (are-connected (user-a principal) (user-b principal))
  (default-to false (get connected (map-get? connections { user-a: user-a, user-b: user-b })))
)

;; Get endorsement
(define-read-only (get-endorsement (endorser principal) (endorsed principal) (skill (string-ascii 50)))
  (map-get? endorsements { endorser: endorser, endorsed: endorsed, skill: skill })
)

;; Check if credential is verified
(define-read-only (is-credential-verified (credential-id uint))
  (match (map-get? credentials { credential-id: credential-id })
    credential (get verified credential)
    false
  )
)

;; Get credential count (helper for frontend)
(define-read-only (get-next-credential-id)
  (var-get next-credential-id)
)

;; Get total number of profiles created
(define-read-only (get-profile-count)
  (- (var-get next-profile-id) u1)
)