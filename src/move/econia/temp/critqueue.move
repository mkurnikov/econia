module econia::critqueue {

    // Uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    use aptos_std::table::{Self, Table};
    use std::option::{Self, Option};

    // Uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only uses >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    use std::vector;

    // Test-only uses <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Structs >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Hybrid between a crit-bit tree and a queue. See above.
    struct CritQueue<V> has store {
        /// Crit-queue sort direction, `ASCENDING` or `DESCENDING`.
        direction: bool,
        /// Crit-bit tree root node key. If none, tree is empty.
        root: Option<u128>,
        /// Queue head key. If none, tree is empty. Else minimum leaf
        /// key if `direction` is `ASCENDING`, and maximum leaf key
        /// if `direction` is `DESCENDING`.
        head: Option<u128>,
        /// Map from enqueue key to 0-indexed enqueue count.
        enqueues: Table<u64, u64>,
        /// Map from inner key to `Inner`.
        inners: Table<u128, Inner>,
        /// Map from leaf key to `Leaf` having enqueue value type `V`.
        leaves: Table<u128, Leaf<V>>
    }

    /// A crit-bit tree inner node.
    struct Inner has store {
        /// Critical bit position.
        bit: u8,
        /// If none, node is root. Else parent key.
        parent: Option<u128>,
        /// Left child key.
        left: u128,
        /// Right child key.
        right: u128
    }

    /// A crit-bit tree leaf node.
    struct Leaf<V> has store {
        /// Enqueue value.
        value: V,
        /// If none, node is root. Else parent key.
        parent: Option<u128>
    }

    // Structs <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Constants >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Ascending crit-queue flag.
    const ASCENDING: bool = false;
    /// Crit-queue direction bit flag indicating `ASCENDING`.
    const ASCENDING_BIT_FLAG: u128 = 0;
    /// Descending crit-queue flag.
    const DESCENDING: bool = true;
    /// Crit-queue direction bit flag indicating `DESCENDING`.
    const DESCENDING_BIT_FLAG: u128 = 1;
    /// Bit number of crit-queue direction bit flag.
    const DIRECTION: u8 = 62;
    /// Number of bits to shift when encoding enqueue key in leaf key.
    const ENQUEUE_KEY: u8 = 64;
    /// `u128` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 128, 2))`.
    const HI_128: u128 = 0xffffffffffffffffffffffffffffffff;
    /// `u64` bitmask with all bits set, generated in Python via
    /// `hex(int('1' * 64, 2))`.
    const HI_64: u64 = 0xffffffffffffffff;
    /// Maximum number of times a given enqueue key can be enqueued.
    /// A `u64` bitmask with all bits set except 62 and 63, generated
    /// in Python via `hex(int('1' * 62, 2))`.
    const MAX_ENQUEUE_COUNT: u64 = 0x3fffffffffffffff;
    /// Most significant bit number for a `u128`
    const MSB_u128: u8 = 127;
    /// `u128` bitmask set at bit 63, the node type bit flag, generated
    /// in Python via `hex(int('1' + '0' * 63, 2))`.
    const NODE_TYPE: u128 = 0x8000000000000000;
    /// Result of bitwise `AND` with `NODE_TYPE` for `Inner` node.
    const NODE_INNER: u128 = 0x8000000000000000;
    /// Result of bitwise `AND` with `NODE_TYPE` for `Leaf` node.
    const NODE_LEAF: u128 = 0;
    /// `XOR` bitmask for flipping all 62 enqueue count bits and setting
    /// bit 63 high in the case of a descending crit-queue. `u64`
    /// bitmask with all bits set except bit 63, generated in Python via
    /// `hex(int('1' * 63, 2))`.
    const NOT_ENQUEUE_COUNT_DESCENDING: u64 = 0x7fffffffffffffff;

    // Constants <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// When an enqueue key has been enqueued too many times.
    const E_TOO_MANY_ENQUEUES: u64 = 0;

    // Error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // To implement >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Dequeue head and borrow next element in the queue, the new head.
    ///
    /// Should only be called after `dequeue_init()` indicates that
    /// iteration can proceed, or if a subsequent call to `dequeue()`
    /// indicates the same.
    ///
    /// # Parameters
    /// * `crit_queue_ref_mut`: Mutable reference to `CritQueue`.
    ///
    /// # Returns
    /// * `u128`: New queue head leaf key.
    /// * `&mut V`: Mutable reference to new queue head enqueue value.
    /// * `bool`: `true` if the new queue head `Leaf` has a parent, and
    ///   thus if iteration can proceed.
    ///
    /// # Aborts if
    /// * Indicated `CritQueue` is empty.
    /// * Indicated `CritQueue` is a singleton, e.g. if there are no
    ///   elements to proceed to after dequeueing.
    public fun dequeue<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>
    )//: (
        //u128,
        //&mut V,
        //bool
    /*)*/ {
        // Can ensure that there is a queue head by attempting to borrow
        // the corresponding leaf key from the option field, which
        // aborts if it is none.
    }

    /// Mutably borrow the head of the queue before dequeueing.
    ///
    /// # Parameters
    /// * `crit_queue_ref_mut`: Mutable reference to `CritQueue`.
    ///
    /// # Returns
    /// * `u128`: Queue head leaf key.
    /// * `&mut V`: Mutable reference to queue head enqueue value.
    /// * `bool`: `true` if the queue `Leaf` has a parent, and thus if
    ///   there is another element to iterate to. If `false`, can still
    ///   remove the head via `remove()`.
    ///
    /// # Aborts if
    /// * Indicated `CritQueue` is empty.
    public fun dequeue_init<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>
    )//: (
        //u128,
        //&mut V,
        //bool
    /*)*/ {
        // Can ensure that there is a queue head by attempting to borrow
        // corresponding leaf key from `CritQueue.head`, which aborts
        // if none.
    }

    /// Enqueue key-value pair, returning generated leaf key.
    public fun enqueue<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>,
        _enqueue_key: u64,
        //_enqueue_value: V,
    )/*: u128*/ {}

    /// Remove corresponding leaf, return enqueue value.
    public fun remove<V>(
        _crit_queue_ref_mut: &mut CritQueue<V>,
        _leaf_key: u128
    )/*: V*/ {}

    // To implement <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Public functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Borrow enqueue value corresponding to given `leaf_key` for given
    /// `CritQueue`.
    public fun borrow<V>(
        crit_queue_ref: &CritQueue<V>,
        leaf_key: u128
    ): &V {
        &table::borrow(&crit_queue_ref.leaves, leaf_key).value
    }

    /// Mutably borrow enqueue value corresponding to given `leaf_key`
    /// for given `CritQueue`.
    public fun borrow_mut<V>(
        crit_queue_ref_mut: &mut CritQueue<V>,
        leaf_key: u128
    ): &mut V {
        &mut table::borrow_mut(&mut crit_queue_ref_mut.leaves, leaf_key).value
    }

    /// Return head leaf key of given `CritQueue`, if any.
    public fun get_head_leaf_key<V>(
        crit_queue_ref: &CritQueue<V>,
    ): Option<u128> {
        crit_queue_ref.head
    }

    /// Return `true` if given `CritQueue` has the given `leaf_key`.
    public fun has_leaf_key<V>(
        crit_queue_ref: &CritQueue<V>,
        leaf_key: u128
    ): bool {
        table::contains(&crit_queue_ref.leaves, leaf_key)
    }

    /// Return `true` if given `CritQueue` is empty.
    public fun is_empty<V>(
        crit_queue_ref: &CritQueue<V>,
    ): bool {
        option::is_none(&crit_queue_ref.root)
    }

    /// Return `ASCENDING` or `DESCENDING` `CritQueue`, per `direction`.
    public fun new<V: store>(
        direction: bool
    ): CritQueue<V> {
        CritQueue{
            direction,
            root: option::none(),
            head: option::none(),
            enqueues: table::new(),
            inners: table::new(),
            leaves: table::new()
        }
    }

    /// Return `true` if, were `enqueue_key` to be enqueued, it would
    /// trail behind the head of the given `CritQueue`.
    public fun would_trail_head<V>(
        crit_queue_ref: &CritQueue<V>,
        enqueue_key: u64
    ): bool {
        // Return false if the crit-queue is empty and has no head.
        if (option::is_none(&crit_queue_ref.head)) false else
            // Otherwise, if the crit-queue is ascending, return true
            // if enqueue key is greater than or equal to the enqueue
            // key encoded in the head leaf key.
            if (crit_queue_ref.direction == ASCENDING) (enqueue_key as u128) >=
                *option::borrow(&crit_queue_ref.head) >> ENQUEUE_KEY
            // Otherwise, if the crit-queue is descending, return true
            // if the enqueue key is less than or equal to the enqueue
            // key encoded in the head leaf key.
            else (enqueue_key as u128) <=
                *option::borrow(&crit_queue_ref.head) >> ENQUEUE_KEY
    }

    /// Return `true` if, were `enqueue_key` to be enqueued, it would
    /// become new the new head of the given `CritQueue`.
    public fun would_become_new_head<V>(
        crit_queue_ref: &CritQueue<V>,
        enqueue_key: u64
    ): bool {
        // Return true if the crit-queue is empty and has no head.
        if (option::is_none(&crit_queue_ref.head)) true else
            // Otherwise, if the crit-queue is ascending, return true
            // if enqueue key is less than the enqueue key encoded in
            // the head leaf key.
            if (crit_queue_ref.direction == ASCENDING) (enqueue_key as u128) <
                *option::borrow(&crit_queue_ref.head) >> ENQUEUE_KEY
            // Otherwise, if the crit-queue is descending, return true
            // if the enqueue key is greater than the enqueue key
            // encoded in the head leaf key.
            else (enqueue_key as u128) >
                *option::borrow(&crit_queue_ref.head) >> ENQUEUE_KEY
    }

    // Public functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Private functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    /// Return the number of the most significant bit (0-indexed from
    /// LSB) at which two non-identical bitstrings, `s1` and `s2`, vary.
    ///
    /// # XOR/AND method
    ///
    /// To begin with, a bitwise XOR is used to flag all differing bits:
    ///
    /// >              s1: 11110001
    /// >              s2: 11011100
    /// >     x = s1 ^ s2: 00101101
    /// >                    |- critical bit = 5
    ///
    /// Here, the critical bit is equivalent to the bit number of the
    /// most significant set bit in XOR result `x = s1 ^ s2`. At this
    /// point, [Langley 2008](#references) notes that `x` bitwise AND
    /// `x - 1` will be nonzero so long as `x` contains at least some
    /// bits set which are of lesser significance than the critical bit:
    ///
    /// >                   x: 00101101
    /// >               x - 1: 00101100
    /// >     x = x & (x - 1): 00101100
    ///
    /// Thus he suggests repeating `x & (x - 1)` while the new result
    /// `x = x & (x - 1)` is not equal to zero, because such a loop will
    /// eventually reduce `x` to a power of two (excepting the trivial
    /// case where `x` starts as all 0 except bit 0 set, for which the
    /// loop never enters past the initial conditional check). Per this
    /// method, using the new `x` value for the current example, the
    /// second iteration proceeds as follows:
    ///
    /// >               x: 00101100
    /// >           x - 1: 00101011
    /// > x = x & (x - 1): 00101000
    ///
    /// The third iteration:
    ///
    /// >                   x: 00101000
    /// >               x - 1: 00100111
    /// >     x = x & (x - 1): 00100000
    //
    /// Now, `x & x - 1` will equal zero and the loop will not begin a
    /// fourth iteration:
    ///
    /// >                 x: 00100000
    /// >             x - 1: 00011111
    /// >     x AND (x - 1): 00000000
    ///
    /// Thus after three iterations a corresponding critical bit bitmask
    /// has been determined. However, in the case where the two input
    /// strings vary at all bits of lesser significance than that of the
    /// critical bit, there may be required as many as `k - 1`
    /// iterations, where `k` is the number of bits in each string under
    /// comparison. For instance, consider the case of the two 8-bit
    /// strings `s1` and `s2` as follows:
    ///
    /// >                  s1: 10101010
    /// >                  s2: 01010101
    /// >         x = s1 ^ s2: 11111111
    /// >                      |- critical bit = 7
    /// >     x = x & (x - 1): 11111110 [iteration 1]
    /// >     x = x & (x - 1): 11111100 [iteration 2]
    /// >     x = x & (x - 1): 11111000 [iteration 3]
    /// >     ...
    ///
    /// Notably, this method is only suggested after already having
    /// identified the varying byte between the two strings, thus
    /// limiting `x & (x - 1)` operations to at most 7 iterations.
    ///
    /// # Binary search method
    ///
    /// For the present implementation, strings are not partitioned into
    /// a multi-byte array, rather, they are stored as `u128` integers,
    /// so a binary search is instead proposed. Here, the same
    /// `x = s1 ^ s2` operation is first used to identify all differing
    /// bits, before iterating on an upper and lower bound for the
    /// critical bit number:
    ///
    /// >              s1: 10101010
    /// >              s2: 01010101
    /// >     x = s1 ^ s2: 11111111
    /// >           u = 7 -|      |- l = 0
    ///
    /// The upper bound `u` is initialized to the length of the string
    /// (7 in this example, but 127 for a `u128`), and the lower bound
    /// `l` is initialized to 0. Next the midpoint `m` is calculated as
    /// the average of `u` and `l`, in this case `m = (7 + 0) / 2 = 3`,
    /// per truncating integer division. Now, the shifted compare value
    /// `s = r >> m` is calculated and updates are applied according to
    /// three potential outcomes:
    ///
    /// * `s == 1` means that the critical bit `c` is equal to `m`
    /// * `s == 0` means that `c < m`, so `u` is set to `m - 1`
    /// * `s > 1` means that `c > m`, so `l` us set to `m + 1`
    ///
    /// Hence, continuing the current example:
    ///
    /// >              x: 11111111
    /// >     s = x >> m: 00011111
    ///
    /// `s > 1`, so `l = m + 1 = 4`, and the search window has shrunk:
    ///
    /// >     x = s1 ^ s2: 11111111
    /// >           u = 7 -|  |- l = 4
    ///
    /// Updating the midpoint yields `m = (7 + 4) / 2 = 5`:
    ///
    /// >              x: 11111111
    /// >     s = x >> m: 00000111
    ///
    /// Again `s > 1`, so update `l = m + 1 = 6`, and the window
    /// shrinks again:
    ///
    /// >     x = s1 ^ s2: 11111111
    /// >           u = 7 -||- l = 6
    /// >     s = x >> m: 00000011
    ///
    /// Again `s > 1`, so update `l = m + 1 = 7`, the final iteration:
    ///
    /// >     x = s1 ^ s2: 11111111
    /// >           u = 7 -|- l = 7
    /// >     s = x >> m: 00000001
    ///
    /// Here, `s == 1`, which means that `c = m = 7`. Notably this
    /// search has converged after only 3 iterations, as opposed to 7
    /// for the linear search proposed above, and in general such a
    /// search converges after $log_2(k)$ iterations at most, where $k$
    /// is the number of bits in each of the strings `s1` and `s2` under
    /// comparison. Hence this search method improves the $O(k)$ search
    /// proposed by [Langley 2008](#references) to $O(log_2(k))$, and
    /// moreover, determines the actual number of the critical bit,
    /// rather than just a bitmask with bit `c` set, as he proposes,
    /// which can also be easily generated via `1 << c`.
    fun get_critical_bit(
        s1: u128,
        s2: u128,
    ): u8 {
        let x = s1 ^ s2; // XOR result marked 1 at bits that differ.
        let l = 0; // Lower bound on critical bit search.
        let u = MSB_u128; // Upper bound on critical bit search.
        loop { // Begin binary search.
            let m = (l + u) / 2; // Calculate midpoint of search window.
            let s = x >> m; // Calculate midpoint shift of XOR result.
            if (s == 1) return m; // If shift equals 1, c = m.
            // Update search bounds.
            if (s > 1) l = m + 1 else u = m - 1;
        }
    }

    /// Return the leaf key corresponding to the given `enqueue_key`
    /// for the indicated `CritQueue`.
    fun get_leaf_key<V>(
        enqueue_key: u64,
        crit_queue_ref_mut: &mut CritQueue<V>
    ): u128 {
        // Borrow mutable reference to enqueue count table.
        let enqueues_ref_mut = &mut crit_queue_ref_mut.enqueues;
        let enqueue_count = 0; // Assume key has not been enqueued.
        // If the key has already been enqueued:
        if (table::contains(enqueues_ref_mut, enqueue_key)) {
            // Borrow mutable reference to enqueue count.
            let enqueue_count_ref_mut =
                table::borrow_mut(enqueues_ref_mut, enqueue_key);
            // Get enqueue count of current enqueue key.
            enqueue_count = *enqueue_count_ref_mut + 1;
            // Assert max enqueue count is not exceeded.
            assert!(enqueue_count <= MAX_ENQUEUE_COUNT, E_TOO_MANY_ENQUEUES);
            // Update enqueue count table.
            *enqueue_count_ref_mut = enqueue_count;
        } else { // If the enqueue key has not been enqueued:
            // Initialize the enqueue count to 0.
            table::add(enqueues_ref_mut, enqueue_key, enqueue_count);
        }; // Enqueue count has been assigned.
        // If a descending crit-queue, flip all bits of the count.
        if (crit_queue_ref_mut.direction == DESCENDING) enqueue_count =
            enqueue_count ^ NOT_ENQUEUE_COUNT_DESCENDING;
        // Return leaf key with encoded enqueue key and enqueue count.
        (enqueue_key as u128) << ENQUEUE_KEY | (enqueue_count as u128)
    }

    /// Return `true` if `node_key` indicates an `Inner` node.
    fun is_inner_key(
        node_key: u128
    ): bool {
        node_key & NODE_TYPE == NODE_INNER
    }

    /// Return `true` if `node_key` indicates a `Leaf`.
    fun is_leaf_key(
        node_key: u128
    ): bool {
        node_key & NODE_TYPE == NODE_LEAF
    }

    /// Return `true` if `key` is set at `bit_number`
    fun is_set(key: u128, bit_number: u8): bool {key >> bit_number & 1 == 1}

    // Private functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only error codes >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// When a char in a bytestring is neither 0 nor 1.
    const E_BIT_NOT_0_OR_1: u64 = 100;

    // Test-only error codes <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Test-only functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test_only]
    /// Return a bitmask with all bits high except for bit `b`,
    /// 0-indexed starting at LSB: bitshift 1 by `b`, XOR with `HI_128`
    fun bit_lo(b: u8): u128 {1 << b ^ HI_128}

    #[test_only]
    /// Return a `u128` corresponding to provided byte string `s`. The
    /// byte should only contain only "0"s and "1"s, up to 128
    /// characters max (e.g. `b"100101...10101010"`).
    public fun u_128(
        s: vector<u8>
    ): u128 {
        let n = vector::length<u8>(&s); // Get number of bits.
        let r = 0; // Initialize result to 0.
        let i = 0; // Start loop at least significant bit.
        while (i < n) { // While there are bits left to review.
            // Get bit under review.
            let b = *vector::borrow<u8>(&s, n - 1 - i);
            if (b == 0x31) { // If the bit is 1 (0x31 in ASCII):
                // OR result with the correspondingly leftshifted bit.
                r = r | 1 << (i as u8);
            // Otherwise, assert bit is marked 0 (0x30 in ASCII).
            } else assert!(b == 0x30, E_BIT_NOT_0_OR_1);
            i = i + 1; // Proceed to next-least-significant bit.
        };
        r // Return result.
    }

    #[test_only]
    /// Return `u128` corresponding to concatenated result of `a`, `b`,
    /// `c`, and `d`. Useful for line-wrapping long byte strings, and
    /// inspection via 32-bit sections.
    public fun u_128_by_32(
        a: vector<u8>,
        b: vector<u8>,
        c: vector<u8>,
        d: vector<u8>,
    ): u128 {
        vector::append<u8>(&mut c, d); // Append d onto c.
        vector::append<u8>(&mut b, c); // Append c onto b.
        vector::append<u8>(&mut a, b); // Append b onto a.
        u_128(a) // Return u128 equivalent of concatenated bytestring.
    }

    // Test-only functions <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    // Tests >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    #[test]
    /// Verify successful bitmask generation
    fun test_bit_lo() {
        assert!(bit_lo(0) == HI_128 - 1, 0);
        assert!(bit_lo(1) == HI_128 - 2, 0);
        assert!(bit_lo(127) == 0x7fffffffffffffffffffffffffffffff, 0);
    }

    #[test]
    /// Verify borrowing, immutably and mutably.
    fun test_borrowers():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Add a mock leaf to the leaves table.
        table::add(&mut crit_queue.leaves, 0,
            Leaf{value: 0, parent: option::none()});
        // Assert correct value borrow.
        assert!(*borrow(&crit_queue, 0) == 0, 0);
        *borrow_mut(&mut crit_queue, 0) = 123; // Mutate value.
        assert!(*borrow(&crit_queue, 0) == 123, 0); // Assert mutation.
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify successful calculation of critical bit at all positions.
    fun test_get_critical_bit() {
        let b = 0; // Start loop for bit 0.
        while (b <= MSB_u128) { // Loop over all bit numbers.
            // Compare 0 versus a bitmask that is only set at bit b.
            assert!(get_critical_bit(0, 1 << b) == b, (b as u64));
            b = b + 1; // Increment bit counter.
        };
    }

    #[test]
    /// Verify lookup returns.
    fun test_get_head_leaf_key():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert no head leaf key indicated.
        assert!(option::is_none(&get_head_leaf_key(&crit_queue)), 0);
        // Set mock head leaf key.
        option::fill(&mut crit_queue.head, 123);
        // Assert head leaf key returned correctly.
        assert!(*option::borrow(&get_head_leaf_key(&crit_queue)) == 123, 0);
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify successful leaf key generation.
    fun test_get_leaf_key():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert successful returns across multiple queries.
        assert!(get_leaf_key(0, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
        ), 0);
        assert!(get_leaf_key(0, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001",
        ), 0);
        assert!(get_leaf_key(0, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000010",
        ), 0);
        *table::borrow_mut(&mut crit_queue.enqueues, 0) =
            MAX_ENQUEUE_COUNT - 1; // Set count to one less than max.
        // Assert can get one final leaf key.
        assert!(get_leaf_key(0, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"00111111111111111111111111111111",
            b"11111111111111111111111111111111",
        ), 0);
        // Flip the enqueue direction.
        crit_queue.direction = DESCENDING;
        // Assert successful returns across multiple queries.
        assert!(get_leaf_key(1, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001",
            b"01111111111111111111111111111111",
            b"11111111111111111111111111111111",
        ), 0);
        assert!(get_leaf_key(1, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001",
            b"01111111111111111111111111111111",
            b"11111111111111111111111111111110",
        ), 0);
        assert!(get_leaf_key(1, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001",
            b"01111111111111111111111111111111",
            b"11111111111111111111111111111101",
        ), 0);
        *table::borrow_mut(&mut crit_queue.enqueues, 1) =
            MAX_ENQUEUE_COUNT - 1; // Set count to one less than max.
        // Assert can get one final leaf key.
        assert!(get_leaf_key(1, &mut crit_queue) == u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000001",
            b"01000000000000000000000000000000",
            b"00000000000000000000000000000000",
        ), 0);
        crit_queue // Return crit-queue.
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    /// Verify failure for exceeding maximum enqueue count.
    fun test_get_leaf_key_too_many_enqueues():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Set count to max.
        table::add(&mut crit_queue.enqueues, 0, MAX_ENQUEUE_COUNT);
        // Attempt to enqueue one more.
        get_leaf_key(0, &mut crit_queue);
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify returns for membership checks.
    fun test_has_leaf_key():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert arbitrary leaf key not contained.
        assert!(!has_leaf_key(&crit_queue, 0), 0);
        // Add a mock leaf to the leaves table.
        table::add(&mut crit_queue.leaves, 0,
            Leaf{value: 0, parent: option::none()});
        // Assert arbitrary leaf key contained.
        assert!(has_leaf_key(&crit_queue, 0), 0);
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify successful returns.
    fun test_is_empty():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert is marked empty.
        assert!(is_empty(&crit_queue), 0);
        option::fill(&mut crit_queue.root, 1234); // Mark mock root.
        // Assert is marked not empty.
        assert!(!is_empty(&crit_queue), 0);
        crit_queue // Return crit-queue.
    }

    #[test]
    /// Verify successful determination of key types.
    fun test_key_types() {
        assert!(is_inner_key(u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000000",
            b"10000000000000000000000000000000",
            b"00000000000000000000000000000000",
        )), 0);
        assert!(is_leaf_key(u_128_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"01111111111111111111111111111111",
            b"11111111111111111111111111111111",
        )), 0);
    }

    #[test]
    /// Verify correct returns.
    fun test_is_set_success() {
        assert!(is_set(u_128(b"11"), 0), 0);
        assert!(is_set(u_128(b"11"), 1), 0);
        assert!(!is_set(u_128(b"10"), 0), 0);
        assert!(!is_set(u_128(b"01"), 1), 0);
    }

    #[test]
    /// Verify successful return values
    fun test_u_128() {
        assert!(u_128(b"0") == 0, 0);
        assert!(u_128(b"1") == 1, 0);
        assert!(u_128(b"00") == 0, 0);
        assert!(u_128(b"01") == 1, 0);
        assert!(u_128(b"10") == 2, 0);
        assert!(u_128(b"11") == 3, 0);
        assert!(u_128(b"10101010") == 170, 0);
        assert!(u_128(b"00000001") == 1, 0);
        assert!(u_128(b"11111111") == 255, 0);
        assert!(u_128_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111"
        ) == HI_128, 0);
        assert!(u_128_by_32(
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111110"
        ) == HI_128 - 1, 0);
    }

    #[test]
    #[expected_failure(abort_code = 100)]
    /// Verify failure for non-binary-representative byte string.
    fun test_u_failure() {u_128(b"2");}

    #[test]
    /// Verify lookup returns.
    fun test_would_become_trail_head():
    CritQueue<u8> {
        let crit_queue = new(ASCENDING); // Get ascending crit-queue.
        // Assert return for value that would become new head.
        assert!(would_become_new_head(&crit_queue, HI_64), 0);
        // Assert return for value that would not trail head.
        assert!(!would_trail_head(&crit_queue, HI_64), 0);
        // Set mock head leaf key.
        option::fill(&mut crit_queue.head, u_128_by_32(
            b"00000000000000000000000000000000",
            b"00000000000000000000000000000010",
            b"11111111111111111111111111111111",
            b"11111111111111111111111111111111",
        ));
        // Assert return for value that would become new head.
        assert!(would_become_new_head(&crit_queue, (u_128(b"01") as u64)), 0);
        // Assert return for value that would not trail head.
        assert!(!would_trail_head(&crit_queue, (u_128(b"01") as u64)), 0);
        // Assert return for value that would not become new head.
        assert!(!would_become_new_head(&crit_queue, (u_128(b"10") as u64)), 0);
        // Assert return for value that would trail head.
        assert!(would_trail_head(&crit_queue, (u_128(b"10") as u64)), 0);
        // Flip crit-queue direction.
        crit_queue.direction = DESCENDING;
        // Assert return for value that would become new head.
        assert!(would_become_new_head(&crit_queue, (u_128(b"11") as u64)), 0);
        // Assert return for value that would not trail head.
        assert!(!would_trail_head(&crit_queue, (u_128(b"11") as u64)), 0);
        // Assert return for value that would not become new head.
        assert!(!would_become_new_head(&crit_queue, (u_128(b"10") as u64)), 0);
        // Assert return for value that would trail head.
        assert!(would_trail_head(&crit_queue, (u_128(b"10") as u64)), 0);
        crit_queue // Return crit-queue.
    }

    // Tests <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

}